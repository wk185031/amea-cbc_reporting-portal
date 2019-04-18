package my.com.mandrill.base.reporting;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.json.JSONException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class GeneralReportProcess implements IReportProcessor {

	private final Logger logger = LoggerFactory.getLogger(GeneralReportProcess.class);
	HashMap<String, ReportGenerationFields> globalFileFieldsMap = new HashMap<String, ReportGenerationFields>();
	String eol = System.lineSeparator();

	public HashMap<String, ReportGenerationFields> getGlobalFileFieldsMap() {
		return globalFileFieldsMap;
	}

	public void setGlobalFileFieldsMap(HashMap<String, ReportGenerationFields> globalFileFieldsMap) {
		this.globalFileFieldsMap = globalFileFieldsMap;
	}

	public String getEol() {
		return eol;
	}

	public void setEol(String eol) {
		this.eol = eol;
	}

	@Override
	public void preProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		addPreProcessingFieldsToGlobalMap(rgm);
		performPreProcessingTransformations(globalFileFieldsMap);
	}

	@Override
	public void postProcessing(ReportGenerationMgr rgm)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		addPostProcessingFieldsToGlobalMap(rgm);
		performPostProcessingTransformations(globalFileFieldsMap);
	}

	protected List<ReportGenerationFields> extractHeaderFields(ReportGenerationMgr rgm)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> headerFields = null;
		if (rgm.getHeaderFields() != null) {
			headerFields = objectMapper.readValue(rgm.getHeaderFields().getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			if (headerFields.size() > 0) {
				headerFields.get(headerFields.size() - 1).setEndOfSection(true);
			}
		}
		return headerFields;
	}

	protected List<ReportGenerationFields> extractBodyHeaderFields(ReportGenerationMgr rgm)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> bodyHeaderFields = null;
		if (rgm.getBodyFields() != null) {
			bodyHeaderFields = objectMapper.readValue(rgm.getBodyFields().getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			bodyHeaderFields = bodyHeaderFields.stream()
					.filter((reportGenerationField) -> reportGenerationField.isBodyHeader() == true)
					.collect(Collectors.toList());
			if (bodyHeaderFields.size() > 0) {
				bodyHeaderFields.get(bodyHeaderFields.size() - 1).setEndOfSection(true);
			}
		}
		return bodyHeaderFields;
	}

	protected List<ReportGenerationFields> extractBodyFields(ReportGenerationMgr rgm)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> bodyFields = null;
		if (rgm.getBodyFields() != null) {
			bodyFields = objectMapper.readValue(rgm.getBodyFields().getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			bodyFields = bodyFields.stream()
					.filter((reportGenerationField) -> reportGenerationField.isBodyHeader() == false)
					.collect(Collectors.toList());
			if (bodyFields.size() > 0) {
				bodyFields.get(bodyFields.size() - 1).setEndOfSection(true);
			}
		}
		return bodyFields;
	}

	protected List<ReportGenerationFields> extractTrailerFields(ReportGenerationMgr rgm)
			throws JSONException, JsonParseException, JsonMappingException, IOException {
		ObjectMapper objectMapper = new ObjectMapper();
		List<ReportGenerationFields> trailerFields = null;
		if (rgm.getTrailerFields() != null) {
			trailerFields = objectMapper.readValue(rgm.getTrailerFields().getBytes(),
					new TypeReference<List<ReportGenerationFields>>() {
					});
			if (trailerFields.size() > 0) {
				trailerFields.get(trailerFields.size() - 1).setEndOfSection(true);
			}
		}
		return trailerFields;
	}

	@Override
	public String getBodyQuery(ReportGenerationMgr rgm) {
		String query = rgm.getBodyQuery();
		StringBuffer sb = new StringBuffer();
		if (query != null) {
			Pattern p = Pattern.compile("[{]\\w+,*\\w*[}]"); // the expression\
			Matcher m = p.matcher(query);
			while (m.find()) {
				String paramName = m.group().substring(1, m.group().length() - 1);
				if (globalFileFieldsMap.containsKey(paramName)) {
					m.appendReplacement(sb, globalFileFieldsMap.get(paramName).format(eol, false, null));
				} else {
					logger.error("No field defined for parameter ", paramName);
				}

			}
			m.appendTail(sb);
		} else {

		}
		return sb.toString();
	}

	@Override
	public String getTrailerQuery(ReportGenerationMgr rgm) {
		String query = rgm.getTrailerQuery();
		StringBuffer sb = new StringBuffer();
		if (query != null) {
			Pattern p = Pattern.compile("[{]\\w+,*\\w*[}]"); // the expression\
			Matcher m = p.matcher(query);
			while (m.find()) {
				String paramName = m.group().substring(1, m.group().length() - 1);
				if (globalFileFieldsMap.containsKey(paramName)) {
					m.appendReplacement(sb, globalFileFieldsMap.get(paramName).format(eol, false, null));
				} else {
					logger.error("No field defined for parameter ", paramName);
				}

			}
			m.appendTail(sb);
		} else {

		}
		return sb.toString();
	}

	protected void addPreProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		// TODO Auto-generated method stub
	}

	protected void addPostProcessingFieldsToGlobalMap(ReportGenerationMgr rgm) {
		// TODO Auto-generated method stub
	}

	protected String getGlobalFieldValue(ReportGenerationFields fieldConfig, boolean fixedLength) {
		String fieldValue = null;
		if (fieldConfig.getDefaultValue() != null && !fieldConfig.getDefaultValue().equalsIgnoreCase("")) {
			fieldValue = fieldConfig.getDefaultValue();
		} else if (globalFileFieldsMap.containsKey(fieldConfig.getFieldName())) {
			fieldValue = globalFileFieldsMap.get(fieldConfig.getFieldName()).getValue();
		} else {
			return null;
		}
		fieldConfig.setValue(fieldValue);

		Integer eky_id = null;
		if (fieldConfig.getFieldType().equalsIgnoreCase(Field.TYPE_ENCRYPTED_STRING)) {
			// eky_id = SecurityManager.getCurrentKeyIndex();
		}
		return fieldConfig.format(eol, fixedLength, eky_id);
	}

	protected String getFieldValue(ReportGenerationFields fieldConfig,
			HashMap<String, ReportGenerationFields> fieldsMap, boolean fixedLength) {
		String fieldValue = null;
		if (fieldConfig.getDefaultValue() != null && !fieldConfig.getDefaultValue().equalsIgnoreCase("")) {
			fieldValue = fieldConfig.getDefaultValue();
		} else if (fieldsMap.containsKey(fieldConfig.getFieldName())) {
			fieldValue = fieldsMap.get(fieldConfig.getFieldName()).getValue();
		} else if (globalFileFieldsMap.containsKey(fieldConfig.getFieldName())) {
			fieldValue = globalFileFieldsMap.get(fieldConfig.getFieldName()).getValue();
		} else {
			return null;
		}
		fieldConfig.setValue(fieldValue);

		Integer eky_id = null;
		if (fieldConfig.getFieldType().equalsIgnoreCase(Field.TYPE_ENCRYPTED_STRING)) {
			// eky_id = SecurityManager.getCurrentKeyIndex();
		}
		return fieldConfig.format(eol, fixedLength, eky_id);
	}

	protected void performPreProcessingTransformations(HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		Map<String, Object> poolDBObjects = new HashMap<String, Object>();
		// for (ActionDescriptor actionDesc :
		// exportDataStructure.getPreProcessingActionsList()) {
		// Class<?> tr = Class.forName(actionDesc.getPath());
		// Class<? extends TransformationI> interfaceClass =
		// tr.asSubclass(TransformationI.class);
		// TransformationI action = interfaceClass.newInstance();
		// Field fieldResult = action.process(fieldsMap, poolDBObjects,
		// actionDesc.getFieldsName(), actionDesc.getResult());
		// if (fieldResult != null) {
		// fieldsMap.put(fieldResult.getName(), fieldResult);
		// }
		//
		// }
	}

	private void performPostProcessingTransformations(HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		Map<String, Object> poolDBObjects = new HashMap<String, Object>();
		// for (ActionDescriptor actionDesc :
		// exportDataStructure.getPostProcessingActionsList()) {
		// Class<?> tr = Class.forName(actionDesc.getPath());
		// Class<? extends TransformationI> interfaceClass =
		// tr.asSubclass(TransformationI.class);
		// TransformationI action = interfaceClass.newInstance();
		// ReportGenerationFields fieldResult = action.process(fieldsMap, poolDBObjects,
		// actionDesc.getFieldsName(),
		// actionDesc.getResult());
		// if (fieldResult != null) {
		// fieldsMap.put(fieldResult.getFieldName(), fieldResult);
		// }
		//
		// }
	}

	protected void performTransformations(HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException {
		Map<String, Object> poolDBObjects = new HashMap<String, Object>();
		// for (ActionDescriptor actionDesc :
		// exportDataStructure.getTransformationActionList()) {
		// Class<?> tr = Class.forName(actionDesc.getPath());
		// Class<? extends TransformationI> interfaceClass =
		// tr.asSubclass(TransformationI.class);
		// TransformationI action = interfaceClass.newInstance();
		// ReportGenerationFields fieldResult = action.process(fieldsMap, poolDBObjects,
		// actionDesc.getFieldsName(),
		// actionDesc.getResult());
		// if (fieldResult != null) {
		// fieldsMap.put(fieldResult.getFieldName(), fieldResult);
		// }
		//
		// }
	}

	@Override
	public void writeHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		extractHeaderFields(rgm);
	}

	@Override
	public void writeBodyHeader(ReportGenerationMgr rgm) throws IOException, JSONException {
		extractBodyHeaderFields(rgm);
	}

	@Override
	public void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		extractBodyFields(rgm);
	}

	@Override
	public void writeTrailer(ReportGenerationMgr rgm) throws IOException, JSONException {
		extractTrailerFields(rgm);
	}

	@Override
	public void writeTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		extractTrailerFields(rgm);
	}

	@Override
	public void writePdfHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading,
			int pagination) throws IOException, JSONException {
		// TODO Auto-generated method stub

	}

	@Override
	public void writePdfBodyHeader(ReportGenerationMgr rgm, PDPageContentStream contentStream, float leading)
			throws IOException, JSONException {
		// TODO Auto-generated method stub

	}

	@Override
	public void writePdfBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading, int success, int pagination)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		// TODO Auto-generated method stub

	}

	@Override
	public void writePdfTrailer(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap,
			PDPageContentStream contentStream, float leading)
			throws IOException, InstantiationException, IllegalAccessException, ClassNotFoundException, JSONException {
		// TODO Auto-generated method stub

	}

	@Override
	public void writeHeader(ReportGenerationMgr rgm, int pagination) throws IOException, JSONException {
		// TODO Auto-generated method stub

	}

	@Override
	public void writeBody(ReportGenerationMgr rgm, HashMap<String, ReportGenerationFields> fieldsMap, int success,
			int pagination)
			throws InstantiationException, IllegalAccessException, ClassNotFoundException, IOException, JSONException {
		// TODO Auto-generated method stub

	}
}
