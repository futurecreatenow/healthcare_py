package com.example.batch.repository;

import org.springframework.stereotype.Repository;

import com.example.batch.entity.Employee;

@Repository
public class EmployeeRepository {

    public Employee findById(int id) {

        return new Employee(id, "山田太郎");
    }
}
