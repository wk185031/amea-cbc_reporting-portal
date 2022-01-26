package my.com.mandrill.base.service.util;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FileUtils {

	private static final Logger log = LoggerFactory.getLogger(FileUtils.class);

	public static String zipFiles(String zipFilename, Path sourceDir, Path destDir) {
		final int BUFFER = 1024;
		BufferedInputStream bis = null;
		ZipOutputStream zos = null;

		File outputFile = Paths.get(destDir.toString(), zipFilename.concat(".zip")).toFile();
		if (outputFile.exists()) {
			log.debug("File already compressed.");
			return outputFile.getAbsolutePath();
		}

		try {
			FileOutputStream fos = new FileOutputStream(outputFile);
			zos = new ZipOutputStream(fos);

			List<File> fileCollections = new ArrayList<>();
			collectFileRecursively(fileCollections, sourceDir.toFile());

			for (File file : fileCollections) {
				if (file.isFile() && !file.getName().endsWith(".zip")) {
					FileInputStream fis = new FileInputStream(file);
					bis = new BufferedInputStream(fis, BUFFER);
					ZipEntry ze = new ZipEntry(getFileName(sourceDir.toString(), file.getAbsolutePath()));
					zos.putNextEntry(ze);
					byte data[] = new byte[BUFFER];
					int count;
					while ((count = bis.read(data, 0, BUFFER)) != -1) {
						zos.write(data, 0, count);
					}
					bis.close();
					zos.closeEntry();
				}
			}

		} catch (Exception e) {
			throw new RuntimeException(e);
		} finally {
			try {
				zos.close();
				if (bis != null)
					bis.close();
			} catch (Exception e) {
				log.warn("Failed to close resource", e);
			}
		}

		return outputFile.getAbsolutePath();
	}

	private static void collectFileRecursively(List<File> fileList, File source) {
		File[] fileNames = source.listFiles();
		for (File file : fileNames) {
			if (file.isDirectory()) {
				fileList.add(file);
				collectFileRecursively(fileList, file);
			} else {
				fileList.add(file);
			}
		}
	}

	private static String getFileName(String sourceDir, String filePath) {
		String name = filePath.substring(sourceDir.length() + 1, filePath.length());
		return name;
	}
	
	public static void splitBranchReportByText(File sourceFile, File destDir) throws Exception{
		PDDocument doc = null;
		PDFTextStripper pdfStripper = new PDFTextStripper();
		try {
			doc = PDDocument.load(sourceFile);
			
			for (int i = 0; i < doc.getNumberOfPages(); i++) {
				pdfStripper.setStartPage(i);
				pdfStripper.setEndPage(i);

				String content = pdfStripper.getText(doc);
				String[] lines = content.split("\r\n|\r|\n");
				
				for (int j=0; j<lines.length;j++) {
					if (j == 1) {
						if (!lines[j].trim().isEmpty()) {
							String branchCode = lines[j].substring(0, 4);
							System.out.println(branchCode);
						}
					}					
				}
			}			
		} finally {
			if (doc != null) {
				try {
					doc.close();
				} catch (Exception e) {

				}
			}
		}
	}

	public static void splitBranchReport(File sourceFile, File destDir, Map<Integer, String> branchPageMap) throws Exception {
		PDDocument doc = null;
		PDDocument branchDoc = null;
		try {
			doc = PDDocument.load(sourceFile);

			int startPage = -1;
			int endPage = -1;
			String branchToProcess = null;

			for (Map.Entry<Integer, String> entry : branchPageMap.entrySet()) {
				
				try {
					branchDoc = new PDDocument();
					String branchCode = entry.getValue();
					int branchPageNumber = entry.getKey();

					if (startPage == -1) {
						startPage = branchPageNumber;
						branchToProcess = branchCode;
					} else if (endPage == -1) {
						endPage = branchPageNumber - 1;
						// start split the document
						log.debug("Split report: [filename={}, branch={}, page={}-{}]", sourceFile.getName(),
								branchToProcess, startPage, endPage);
						for (int i = startPage; i <= endPage; i++) {
							//PDF getPage start at 0
							branchDoc.importPage(doc.getPage(i-1));
						}
						branchDoc.save(Paths.get(destDir.toString(), branchToProcess.concat(".pdf")).toFile());

						startPage = branchPageNumber;
						branchToProcess = branchCode;
						endPage = -1;
					}
				} finally {
					if (branchDoc != null) {
						try {
							branchDoc.close();
						} catch (Exception e) {

						}
					}
				}
			}

			// process last one
			branchDoc = new PDDocument();
			endPage = doc.getPages().getCount();
			log.debug("Split report: [filename={}, branch={}, page={}-{}]", sourceFile.getName(),
					branchToProcess, startPage, endPage);
			for (int i = startPage; i <= endPage; i++) {
				branchDoc.importPage(doc.getPage(i-1));
			}
			branchDoc.save(Paths.get(destDir.toString(), branchToProcess.concat(".pdf")).toFile());

		} finally {
			if (doc != null) {
				try {
					doc.close();
				} catch (Exception e) {

				}
			}
			if (branchDoc != null) {
				try {
					branchDoc.close();
				} catch (Exception e) {

				}
			}
		}
	}

	public static void main(String[] args) throws Exception {
		Map<Integer, String> branchPageMap = new LinkedHashMap<>();
		branchPageMap.put(1, "1001");
		branchPageMap.put(2, "1002");
		branchPageMap.put(3, "1003");
		branchPageMap.put(5, "1004");
		branchPageMap.put(489, "5008");

		File sourceFile = new File(
				"D:\\MyTemp\\cbc\\reporting\\out\\22\\2021-11\\01\\6716\\MAIN\\ATM Transaction Lists (Branch Reports)\\List of ATM Withdrawals Report 20211101 0000AM-20211130 1159PM.pdf");
		File destDir = new File("D:\\\\MyTemp\\\\cbc\\\\reporting\\\\out\\\\22\\\\2021-11\\\\01\\\\6716\\\\MAIN\\\\ATM Transaction Lists (Branch Reports)");
		//splitBranchReport(sourceFile, destDir, branchPageMap);
		
		splitBranchReportByText(sourceFile, destDir);
		
	}
}