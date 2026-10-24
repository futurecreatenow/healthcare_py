package com.example.batch.service;

import org.springframework.stereotype.Service;

import com.example.batch.dto.EmployeeDto;
import com.example.batch.entity.Employee;
import com.example.batch.repository.EmployeeRepository;

@Service
public class EmployeeService {

    private final EmployeeRepository repository;

    public EmployeeService(
            EmployeeRepository repository) {
        this.repository = repository;
    }

    public EmployeeDto getEmployee(int id) {

        Employee employee =
                repository.findById(id);

        return new EmployeeDto(
                employee.getName());
    }
}
