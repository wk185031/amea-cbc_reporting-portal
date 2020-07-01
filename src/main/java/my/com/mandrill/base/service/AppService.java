package my.com.mandrill.base.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import my.com.mandrill.base.domain.AppResource;
import my.com.mandrill.base.domain.Branch;
import my.com.mandrill.base.domain.Institution;
import my.com.mandrill.base.domain.InstitutionStructure;
import my.com.mandrill.base.domain.RoleExtra;
import my.com.mandrill.base.domain.UserExtra;
import my.com.mandrill.base.repository.BranchRepository;
import my.com.mandrill.base.repository.InstitutionRepository;
import my.com.mandrill.base.repository.UserExtraRepository;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Service related to permissions & multi-institutions.
 *
 */
@Service
@Transactional
public class AppService {

    private final Logger log = LoggerFactory.getLogger(AppService.class);

	private final UserExtraRepository userExtraRepository;

	private final InstitutionRepository institutionRepository;

	private final BranchRepository branchRepository;


	public AppService(
			UserExtraRepository userExtraRepository,
			InstitutionRepository institutionRepository,
			BranchRepository branchRepository) {
		this.userExtraRepository = userExtraRepository;
		this.institutionRepository = institutionRepository;
		this.branchRepository = branchRepository;
	}
	
	//Get Branches of companies
	public Set<Branch> getAllBranchWithChildsOfUser(String user) {
        log.debug("Finding all branches accessible by user " + user);
        Set<Branch> companyBranch = new HashSet<>();

        List<UserExtra> userExtraList = userExtraRepository.findByUserLogin(user);
        if (userExtraList == null || userExtraList.isEmpty()) {
            log.warn("User is not linked to UserExtra entity");
            return companyBranch;
        }

        // User is surely only linked to 1 UserExtra
        UserExtra userExtra = userExtraList.get(0);

        log.debug("Companies accessible by user: " + userExtra.getBranches());
        for(Branch userBranch:userExtra.getBranches()){
            if(!companyBranch.contains(userBranch)) {
            	companyBranch.add(userBranch);
            }
        }
        return companyBranch;
    }
	
	/**
	 * Get all accessible companies for a given user.
	 *
	 * @param user logged in username
	 * @return set of accessible companies
	 */
	public Set<Institution> getAllInstitutionOfUser(String user) {
		log.debug("Finding all companies accessible by user " + user);
		Set<Institution> companies = new HashSet<>();

		List<UserExtra> userExtraList = userExtraRepository.findByUserLogin(user);
		if (userExtraList == null || userExtraList.isEmpty()) {
			log.warn("User is not linked to UserExtra entity");
			return companies;
		}

		// User is surely only linked to 1 UserExtra
		UserExtra userExtra = userExtraList.get(0);

		log.debug("Companies accessible by user: " + userExtra.getInstitutions());
		return userExtra.getInstitutions();
	}
    
    /**
     * Get all accessible companies for a given user.
     *
     * @param user logged in username
     * @return set of accessible companies
     */
    public Set<Institution> getAllInstitutionWithChildsOfUser(String user) {
        log.debug("Finding all companies accessible by user " + user);
        Set<Institution> companies = new HashSet<>();

        List<UserExtra> userExtraList = userExtraRepository.findByUserLogin(user);
        if (userExtraList == null || userExtraList.isEmpty()) {
            log.warn("User is not linked to UserExtra entity");
            return companies;
        }

        // User is surely only linked to 1 UserExtra
        UserExtra userExtra = userExtraList.get(0);

        log.debug("Companies accessible by user: " + userExtra.getInstitutions());
        for(Institution userInstitution:userExtra.getInstitutions()){
            if(!companies.contains(userInstitution)) {
                companies.add(userInstitution);
                getChilds(userInstitution, companies);
            }
        }
        return companies;
    }
    
	public Set<AppResource> getPermissionsForUser(String user) {
		log.debug("Finding all permissions by user " + user);
		Set<AppResource> permissions = new HashSet<>();

		List<UserExtra> userExtraList = userExtraRepository.findByUserLogin(user);
		if (userExtraList == null || userExtraList.isEmpty()) {
			log.warn("User is not linked to UserExtra entity");
			return permissions;
		}

		// User is surely only linked to 1 UserExtra
		UserExtra userExtra = userExtraList.get(0);

		for (RoleExtra role : userExtra.getRoles()) {
			permissions.addAll(role.getPermissions());
		}

		return permissions;
	}

    public List<InstitutionStructure> generateInstitutionStructure(Long id){
        List<Institution> childs = institutionRepository.findAllInstitutionByParentId(id);
        List<InstitutionStructure> structures = new ArrayList<>();
        for(Institution i : childs){
            InstitutionStructure is = new InstitutionStructure(i);
            buildTree(is);
            structures.add(is);
        }
        return structures;
    }

    public boolean buildTree(InstitutionStructure i){
        if(i==null){
            return true;
        }else{
            List<Institution> childs = institutionRepository.findAllInstitutionByParentId(i.getId());
            if(childs==null)
                buildTree(null);
            else {
                log.info(i.getName()+" . childs -> "+childs.size());
                for (Institution ch : childs) {
                    InstitutionStructure child = new InstitutionStructure(ch);
                    buildTree(child);
                    i.addChildren(child);
                }
            }
        }
        return false;
    }

    public boolean getChilds(Institution c,Set<Institution> institutions){
        if(c==null){
            return true;
        }else{
            List<Institution> childs = institutionRepository.findAllInstitutionByParentId(c.getId());
            if(childs==null)
                getChilds(null,institutions);
            else {
                //log.info(c.getName()+" . childs -> "+childs.size());
                for (Institution child : childs) {
                    getChilds(child,institutions);
                    //c.addChildren(child);
                    institutions.add(child);
                }
            }
        }
        return false;
    }
}
