package br.com.gabxdev.controller;

import datadog.trace.api.Trace;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
public class TestController {


    @GetMapping("/testando")
    public ResponseEntity<String> test() throws InterruptedException {
        log.info("Received request test");

        tracer();

        return ResponseEntity.ok("Test");
    }

    @Trace(resourceName = "trace.personalizado", operationName = "testando.trace", measured = true)
    private void tracer() throws InterruptedException {
        Thread.sleep(1000);
    }
}
