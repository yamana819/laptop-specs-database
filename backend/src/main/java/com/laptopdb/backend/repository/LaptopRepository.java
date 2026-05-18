package com.laptopdb.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.laptopdb.backend.entity.Laptop;

@Repository
public interface LaptopRepository extends JpaRepository<Laptop, Integer>, JpaSpecificationExecutor<Laptop> {
    
    @Query("SELECT DISTINCT l.brand FROM Laptop l")
    List<String> findDistinctBrands();

    @Query("SELECT DISTINCT l.gpu.modelName FROM Laptop l")
    List<String> findDistinctGpuModels();
}