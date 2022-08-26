package my.com.mandrill.base.reporting;

import java.io.FileOutputStream;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import my.com.mandrill.base.reporting.ReportGenerationFields;
import my.com.mandrill.base.cbc.processor.SimpleReportProcessor;
import my.com.mandrill.base.reporting.reportProcessor.ReportContext;
import my.com.mandrill.base.writer.CsvWriter;
@Component
public class ListOfGroupRole extends SimpleReportProcessor{
	@Override
	protected String getDelimiter() {
		return CsvWriter.DELIMITER_SEMICOLON;
	}
	
	private final Logger logger = LoggerFactory.getLogger(ListOfGroupRole.class);
	private List<String> roleIdList = new ArrayList<String>();
	
	private void retrieveRoleId(ReportGenerationMgr rgm) {
		ResultSet rs = null;
		PreparedStatement ps = null;
		
		String query = "select DISTINCT re1.NAME as Role_ID " + "from ROLE_EXTRA re1 "
				+ " join USER_EXTRA_ROLES uer1 on uer1.ROLES_ID = re1.ID "
				+ " join USER_EXTRA ue1 on ue1.ID = uer1.USER_EXTRAS_ID "
				+ " join JHI_USER ju1 on ju1.ID = ue1.USER_ID "
				+ " order by re1.NAME ";

		logger.info("Query for body line export: {}", query);
		if (query != null && !query.isEmpty()) {
			try {
				ps = rgm.getConnection().prepareStatement(query);
				rs = ps.executeQuery();

				while (rs.next()) {
					try {
						roleIdList.add(rs.getString("ROLE_ID"));
					} catch (SQLException e) {
						rgm.errors++;
						logger.error("An error was encountered when trying to write a line", e);
						continue;
					}

				}

			} catch (Exception e) {
				rgm.errors++;
				logger.error("Error trying to execute the body query", e);
			} finally {
				rgm.cleanAllDbResource(ps, rs);
			}
		}
	}
	@Override
	protected void writeBodyData(ReportContext context, List<ReportGenerationFields> bodyFields, FileOutputStream out)
			throws Exception {

		StringBuilder line = new StringBuilder();
		for (ReportGenerationFields field : bodyFields) {
			if (field.isGroup()) {
				handleGroupFieldInBody(context, field, line);
			} else {
				String fieldValue = getFormattedFieldValue(field, context);
				
				if (ReportGenerationFields.TYPE_NUMBER.equals(field.getFieldType())
						|| ReportGenerationFields.TYPE_DECIMAL.equals(field.getFieldType())) {
					line.append("\"" + fieldValue + "\"");
					addToSumField(context, field);
				} else {
					line.append(fieldValue);
				}
				line.append(field.getDelimiter());

				if (field.isEol()) {
					line.append(CsvWriter.EOL);
				}
			}
		}
		if(!roleIdList.contains(line.toString())) {
			csvWriter.writeLine(out, line.toString());
			roleIdList.add(line.toString());
			context.setTotalRecord(context.getTotalRecord() + 1);
		} 
	}

}
