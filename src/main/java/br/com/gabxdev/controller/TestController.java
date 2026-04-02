package br.com.gabxdev.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
public class TestController {


    @GetMapping
    public ResponseEntity<String> test() {
        log.info("Received request test");

        return ResponseEntity.ok("Test");
    }
}
