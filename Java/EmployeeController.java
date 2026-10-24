package com.example.batch.controller;

import org.springframework.stereotype.Component;

import com.example.batch.dto.EmployeeDto;
import com.example.batch.service.EmployeeService;

@Component
public class EmployeeController {

    private final EmployeeService service;

    public EmployeeController(
            EmployeeService service) {
        this.service = service;
    }

    public void execute() {

        EmployeeDto dto =
                service.getEmployee(1);

        System.out.println(
                "社員名 : "
                + dto.getEmployeeName());
    }
}
