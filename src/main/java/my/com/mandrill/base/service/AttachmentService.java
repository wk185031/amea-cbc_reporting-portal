package my.com.mandrill.base.service;

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Set;

import javax.imageio.ImageIO;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.jpeg.JpegDirectory;

import my.com.mandrill.base.config.ApplicationProperties;
import my.com.mandrill.base.domain.Attachment;
import my.com.mandrill.base.domain.AttachmentGroup;
import my.com.mandrill.base.repository.AttachmentGroupRepository;
import my.com.mandrill.base.repository.AttachmentRepository;
import my.com.mandrill.base.repository.search.AttachmentGroupSearchRepository;
import my.com.mandrill.base.repository.search.AttachmentSearchRepository;
import my.com.mandrill.base.web.rest.AccountResource;
import my.com.mandrill.base.web.rest.util.HeaderUtil;

@Service
public class AttachmentService {

	private final Logger log = LoggerFactory.getLogger(AttachmentService.class);

	private static final String ENTITY_NAME = "attachment";

	private final AttachmentGroupRepository attachmentGroupRepository;

    private final AttachmentGroupSearchRepository attachmentGroupSearchRepository;

    private final AttachmentRepository attachmentRepository;

    private final AttachmentSearchRepository attachmentSearchRepository;

//    private static final String FOLDER_NAME = "attachment";

    private static final String SMALL_SUFFIX = "-small";

    private final AccountResource accountResource;

    private final ApplicationProperties applicationProperties;

    public AttachmentService(AttachmentGroupRepository attachmentGroupRepository,
                             AttachmentGroupSearchRepository attachmentGroupSearchRepository,
                             AttachmentRepository attachmentRepository,
                             AttachmentSearchRepository attachmentSearchRepository,
                             AccountResource accountResource,
                             ApplicationProperties applicationProperties){
    	this.attachmentGroupRepository = attachmentGroupRepository;
    	this.attachmentGroupSearchRepository = attachmentGroupSearchRepository;
    	this.attachmentRepository = attachmentRepository;
    	this.attachmentSearchRepository = attachmentSearchRepository;
    	this.accountResource = accountResource;
    	this.applicationProperties = applicationProperties;
}

    public <T> AttachmentGroup createAttachmentGroup(Class<T> object){
    	synchronized (this) {
    		AttachmentGroup attachmentGroup = new AttachmentGroup();
    		attachmentGroup.setEntity(object.getSimpleName());
        	AttachmentGroup attachmentGroupResult = attachmentGroupRepository.save(attachmentGroup);
        	attachmentGroupSearchRepository.save(attachmentGroupResult);
        	return attachmentGroupResult;
		}
    }

    public ResponseEntity<List<Attachment>> saveInstitutionAttachment(AttachmentGroup attachmentGroup, Set<Attachment> attachments) throws Exception{
    	if(attachments.size() == 0){
    		return null;
    	}
        List<Attachment> attachmentResult = new ArrayList<>();
        for(Attachment attachment: attachments){
        	if (attachment.getId() != null) {
        	    if (attachment.getRemoveFlag()){
                    attachmentRepository.delete(attachment.getId());
                    attachmentSearchRepository.delete(attachment.getId());
                    removeFile(attachment);
                }
            } else {
                if(attachment.getBlobFile()!=null){
                    try {
                        attachment.setAttachmentGroup(attachmentGroup);
                        if(attachment.getType().equals("Image")){
                            attachment.setName(attachment.getName()+".jpeg");
                            writeImageFiles(attachment);
                        }
                        else{
                            attachment.setName(attachment.getName()+".mp4");
                            writeVideoFiles(attachment);
                        }

                        attachment = attachmentRepository.save(attachment);
                        attachmentSearchRepository.save(attachment);
                        attachmentResult.add(attachment);
                    } catch (Exception e) {
                        log.error("Error while writing the image files", e);
                        return ResponseEntity.badRequest().headers(HeaderUtil.createFailureAlert(ENTITY_NAME, "filename", "Failed to upload")).body(null);
                    }
                }
            }
        }
        return ResponseEntity.ok().body(attachmentResult);
    }

    private void removeFile(Attachment attachment) throws Exception {
        String folderPath = getNewFolderPath(attachment);

        File imageExist = new File(folderPath + attachment.getName());
        if(imageExist.exists()){
            try {
                imageExist.delete();
            } catch (Exception e){
                log.error("Error while deleting the files", e);
            }
        }

        // extracts extension of output file
        String formatName = attachment.getName().substring(attachment.getName().lastIndexOf(".") + 1);
        String imageFileName = attachment.getName().substring(0, attachment.getName().lastIndexOf("."));
        String smallFilePath = folderPath+imageFileName+SMALL_SUFFIX+"."+formatName;

        imageExist = new File(smallFilePath);
        if(imageExist.exists()){
            try {
                imageExist.delete();
            } catch (Exception e){
                log.error("Error while deleting the files", e);
            }
        }
    }

    private void writeVideoFiles(Attachment attachment) throws Exception {
    	String folderPath = getNewFolderPath(attachment);
		File dir = new File(folderPath);
        if (!dir.exists()) {
        	dir.mkdirs();
        }
        File imageExist = new File(folderPath + attachment.getName());
        if(imageExist.exists()){
        	throw new IOException("File "+imageExist+" already exist");
        }
        log.debug("Writing original file to "+imageExist.getAbsolutePath());
        FileOutputStream fos = new FileOutputStream(folderPath + attachment.getName());
        byte[] byteArray = Base64.getMimeDecoder().decode(attachment.getBlobFile());
        fos.write(byteArray);
        fos.close();
        log.debug("Written original file to "+imageExist.getAbsolutePath());
    }

    public void writeImageFiles(Attachment attachment) throws Exception {
		String folderPath = getNewFolderPath(attachment);
		File dir = new File(folderPath);
        if (!dir.exists()) {
        	dir.mkdirs();
        }
        File imageExist = new File(folderPath + attachment.getName());
        if(imageExist.exists()){
        	throw new IOException("File "+imageExist+" already exist");
        }
        log.debug("Writing original file to "+imageExist.getAbsolutePath());
        FileOutputStream fos = new FileOutputStream(folderPath + attachment.getName());
        byte[] byteArray = Base64.getMimeDecoder().decode(attachment.getBlobFile());
        fos.write(byteArray);
        fos.close();
        log.debug("Written original file to "+imageExist.getAbsolutePath());

        // reads input image
        File inputFile = new File(folderPath + attachment.getName());
        BufferedImage inputImage = ImageIO.read(inputFile);

        // rotate
        Metadata metadata = ImageMetadataReader.readMetadata(inputFile);
        ExifIFD0Directory exifIFD0Directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
        JpegDirectory jpegDirectory = (JpegDirectory) metadata.getFirstDirectoryOfType(JpegDirectory.class);
        int orientation = 1;
        if (exifIFD0Directory != null) {
        	orientation = exifIFD0Directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
        }
        int width = jpegDirectory.getImageWidth();
        int height = jpegDirectory.getImageHeight();
        AffineTransform affineTransform = new AffineTransform();

    	BufferedImage rotatedImage = null;
        switch (orientation) {
        case 1:
            break;
        case 3: // PI rotation
            affineTransform.rotate(Math.toRadians(180), width/2, height/2);
            rotatedImage = new BufferedImage(inputImage.getWidth(), inputImage.getHeight(), inputImage.getType());
            break;
        case 6: // -PI/2 and -width
            affineTransform.rotate(Math.toRadians(90), width/2, height/2);
            rotatedImage = new BufferedImage(inputImage.getHeight(), inputImage.getWidth(), inputImage.getType());
            break;
        case 8: // PI / 2
            affineTransform.rotate(Math.toRadians(-90), width/2, height/2);
            rotatedImage = new BufferedImage(inputImage.getHeight(), inputImage.getWidth(), inputImage.getType());
            break;
        default:
            break;
        }

        AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
        rotatedImage = affineTransformOp.filter(inputImage, rotatedImage);

        int targetWidth = 200;
        double scale = (double) targetWidth / rotatedImage.getWidth();
        int targetHeight = (int) (rotatedImage.getHeight() * scale);

        // creates output image
        BufferedImage outputImage = new BufferedImage(targetWidth,
                targetHeight, inputImage.getType());

        // scales the input image to the output image
        Graphics2D g2d = outputImage.createGraphics();
        g2d.drawImage(rotatedImage, 0, 0, targetWidth, targetHeight, null);
        g2d.dispose();

        // extracts extension of output file
        String formatName = attachment.getName().substring(attachment.getName().lastIndexOf(".") + 1);
        String imageFileName = attachment.getName().substring(0, attachment.getName().lastIndexOf("."));
        String smallFilePath = folderPath+imageFileName+SMALL_SUFFIX+"."+formatName;

        log.debug("Writing small file to "+smallFilePath);
        ImageIO.write(outputImage, formatName, new File(smallFilePath));
        log.debug("Written small file to "+smallFilePath);
    }

    public String getNewFolderPath(Attachment attachment) {
//    	String home = System.getProperty("user.home");
        String home = applicationProperties.getImageAttachmentBasePath().getPath();
        String path = home
//        		+ File.separator
//        		+ FOLDER_NAME
//        		+ File.separator
//        		+ attachment.getInstitution().getId()
        		+ File.separator
        		+ attachment.getAttachmentGroup().getId() + File.separator;
        log.debug("Attachment folder path: {}", path);
        return path;
    }
}
