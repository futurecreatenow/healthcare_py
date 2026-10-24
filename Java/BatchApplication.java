package com.example.batch;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import com.example.batch.controller.EmployeeController;

@SpringBootApplication
public class BatchApplication
        implements CommandLineRunner {

    private final EmployeeController controller;

    public BatchApplication(
            EmployeeController controller) {
        this.controller = controller;
    }

    public static void main(String[] args) {

        SpringApplication.run(
                BatchApplication.class,
                args);
    }

    @Override
    public void run(String... args) {

        System.out.println(
                "=== バッチ開始 ===");

        controller.execute();

        System.out.println(
                "=== バッチ終了 ===");
    }
}
