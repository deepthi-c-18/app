package springboot.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Home Page Controller
 */
@Controller
public class HomeController {
    
    @GetMapping("/")
    public String index() {
        return "index";
    }
}
