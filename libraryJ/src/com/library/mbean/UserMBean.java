package com.library.mbean;

import java.io.Serializable;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.validator.ValidatorException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.core.MediaType;

import com.library.entity.User;
import com.library.entity.xml.MessageReturn;
import com.library.util.FacesUtil;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.GenericType;
import com.sun.jersey.api.client.WebResource;

@SessionScoped
@ManagedBean(name = "userMBean")
public class UserMBean implements Serializable {

	private static final long serialVersionUID = 1L;

	// captura a sess�o do contexto criado pelo JavaServer Faces
	FacesContext fc = FacesContext.getCurrentInstance();

	HttpSession session = (HttpSession) fc.getExternalContext().getSession(false);
	
	private List<User> userList;

	private User user;

	private User loggedUser;

	private User[] selectedUsers;

	private Boolean isAdmin = false;
	
	private Boolean showPassword = true;
	
	private String logoutURL;

	Client client = null;

	String host = null;

	public UserMBean() {
		client = Client.create();
		this.user = new User();
		Object request = FacesContext.getCurrentInstance().getExternalContext().getRequest();
		if (request instanceof HttpServletRequest) {
			String[] str = ((HttpServletRequest) request).getRequestURL().toString().split("library");
			host = str[0];
		}
		logoutURL = host+"/libraryJ";
	}

	public String login() {
		MessageReturn ret = new MessageReturn();

		try {

			WebResource webResource = client.resource(host + "libraryWS/user");

			ClientResponse response = webResource.type(MediaType.APPLICATION_JSON).put(ClientResponse.class, user);

			if (response.getStatus() != 201 && response.getStatus() != 200) {
				throw new Exception("Failed : HTTP error code : " + response.getStatus());
			}

			ret = response.getEntity(MessageReturn.class);

			if (ret.getUser() == null) {
				throw new Exception(ret.getMessage());
			} else {
				loggedUser = ret.getUser();
				FacesUtil.showSuccessMessage(ret.getMessage());
			}
		} catch (Exception e) {
			e.printStackTrace();
			FacesUtil.showAErrorMessage(e.getMessage());
			return "";
		}

		return "/common/index.xhtml?faces-redirect=true";
	}
	
	private void loadList(){
		WebResource webResource = client.resource(host + "libraryWS/user");
		
		userList = webResource.accept(MediaType.APPLICATION_JSON).get(new GenericType<List<User>>(){});
	}

	public String list() {
		
		loadList();
		
		return "/common/listUser.xhtml?faces-redirect=true";
	}

	public String logout() {
		this.loggedUser = null;
		return logoutURL;
	}

	public void newUser() {
		this.user = new User();
		showPassword = true;
	}
	
	public void newAdminUser() {
		this.user = new User();
		isAdmin = true;
		showPassword = true;
	}

	public String cancel() {
		this.user = new User();
		return "index.xhtml\faces-redirect=true";
	}

	public void edit() {
		isAdmin = true;
		showPassword = false;
	}

	public String save() {
		MessageReturn ret = new MessageReturn();
		try {
			WebResource webResource = client.resource(host + "libraryWS/user");

			if(!isAdmin){
				user.setAdmin(false);
			}

			ClientResponse response = webResource.type(MediaType.APPLICATION_JSON).post(ClientResponse.class, user);

			if (response.getStatus() != 201 && response.getStatus() != 200) {
				ret.setMessage("Failed : HTTP error code : " + response.getStatus());
				throw new Exception(ret.getMessage());
			}

			ret = response.getEntity(MessageReturn.class);

			if (ret.getUser() == null) {
				throw new Exception(ret.getMessage());
			} else {
				FacesUtil.showSuccessMessage(ret.getMessage());
			}
			if(isAdmin){
				loadList();
			}
		} catch (Exception e) {
			e.printStackTrace();
			FacesUtil.showAErrorMessage(ret.getMessage());
		}
		return "";
	}

	public void delete() {
		MessageReturn ret = new MessageReturn();
		try {
			for (User user : selectedUsers) {
				WebResource webResource = client.resource(host + "libraryWS/user/" + user.getId());

				ClientResponse response = webResource.type(MediaType.APPLICATION_JSON).delete(ClientResponse.class);

				if (response.getStatus() != 201 && response.getStatus() != 200) {
					ret.setMessage("Failed : HTTP error code : " + response.getStatus());
					throw new Exception(ret.getMessage());
				}

				ret = response.getEntity(MessageReturn.class);
			}

			if (selectedUsers.length > 1) {
				FacesUtil.showSuccessMessage("Usu�rios excluidos com sucesso!");
			} else {
				FacesUtil.showSuccessMessage(ret.getMessage());
			}
			loadList();
		} catch (Exception e) {
			e.printStackTrace();
			FacesUtil.showAErrorMessage(ret.getMessage());
		}
	}

	public void checkEmail() throws ValidatorException {
		String digitado = this.user.getEmail();
		Pattern p = Pattern.compile(".+@.+\\.[a-z]+");
		Matcher m = p.matcher(digitado);
		boolean matchFound = m.matches();

		if (!matchFound) {
			FacesMessage message = new FacesMessage("Email invalido, favor verificar");
			message.setSeverity(FacesMessage.SEVERITY_ERROR);
			FacesContext.getCurrentInstance().addMessage("", message);
		}
	}

	public void existsEmail() throws ValidatorException {
		String email = this.user.getEmail();
		this.user.setEmail(email);
		Boolean exists = false; // userBO.existsEmail(this.user);
		if (this.user.getId() == null && exists) {
			FacesMessage message = new FacesMessage("Este email ja esta cadastrado em nosso servi�o!");
			message.setSeverity(FacesMessage.SEVERITY_ERROR);
			FacesContext.getCurrentInstance().addMessage("", message);
		}
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public Boolean getIsAdmin() {
		return isAdmin;
	}

	public void setIsAdmin(Boolean isAdmin) {
		this.isAdmin = isAdmin;
	}

	public User[] getSelectedUsers() {
		return selectedUsers;
	}

	public void setSelectedUsers(User[] selectedUsers) {
		this.selectedUsers = selectedUsers;
	}

	public List<User> getUserList() {
		return userList;
	}

	public void setUserList(List<User> userList) {
		this.userList = userList;
	}

	public Boolean getShowPassword() {
		return showPassword;
	}

	public void setShowPassword(Boolean showPassword) {
		this.showPassword = showPassword;
	}

	public String getLogoutURL() {
		return logoutURL;
	}

	public void setLogoutURL(String logoutURL) {
		this.logoutURL = logoutURL;
	}

	public User getLoggedUser() {
		return loggedUser;
	}

	public void setLoggedUser(User loggedUser) {
		this.loggedUser = loggedUser;
	}

}
