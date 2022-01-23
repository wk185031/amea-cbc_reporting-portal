package my.com.mandrill.base.service.util;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

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

//	public static String zipFiles(String zipFilename, Path sourceDir, Path destDir) {
//		File zipFile = Paths.get(destDir.toString(), zipFilename.concat(".zip")).toFile();
//		if (zipFile.exists()) {
//			zipFile.delete();
//		}
//		log.debug("zipFiles: zipFilename={}, sourceDir={}, destDir={}", zipFilename, sourceDir, destDir);
//
//		try (FileOutputStream fos = new FileOutputStream(zipFile); ZipOutputStream zos = new ZipOutputStream(fos)) {
//
//			Files.walkFileTree(sourceDir, new SimpleFileVisitor<Path>() {
//				@Override
//				public FileVisitResult preVisitDirectory(final Path dir, final BasicFileAttributes attrs)
//						throws IOException {
//					if (!sourceDir.equals(dir)) {
//						zos.putNextEntry(new ZipEntry(sourceDir.relativize(dir).toString()));
//						zos.closeEntry();
//					}
//					return FileVisitResult.CONTINUE;
//				}
//
//				@Override
//				public FileVisitResult visitFile(final Path file, final BasicFileAttributes attrs) throws IOException {
//					if (!file.endsWith(".zip")) {
//						zos.putNextEntry(new ZipEntry(sourceDir.relativize(file).toString()));
//						Files.copy(file, zos);
//						zos.closeEntry();
//						return FileVisitResult.CONTINUE;
//					} else {
//						return FileVisitResult.SKIP_SIBLINGS;
//					}		
//				}
//			});
//		} catch (IOException e) {
//			throw new RuntimeException(e);
//		}
//		log.debug("zip completed: output file path={}", zipFile.getAbsolutePath());
//		return zipFile.getAbsolutePath();
//	}

}
