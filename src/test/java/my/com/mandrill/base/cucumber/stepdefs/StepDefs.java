package my.com.mandrill.base.cucumber.stepdefs;

import my.com.mandrill.base.BaseApp;

import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.ResultActions;

import org.springframework.boot.test.context.SpringBootTest;

@WebAppConfiguration
@SpringBootTest
@ContextConfiguration(classes = BaseApp.class)
public abstract class StepDefs {

    protected ResultActions actions;

}
