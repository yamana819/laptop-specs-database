package com.laptopdb.backend.entity;

import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data 
@Entity 
@Table(name = "cpus") 
public class Cpu {

    @Id 
    @GeneratedValue(strategy = GenerationType.IDENTITY) 
    private Integer id;

    @NotBlank(message = "Brand cannot be blank")
    @Column(nullable = false, length = 50)
    private String brand;

    @NotBlank(message = "Series cannot be blank")
    @Column(nullable = false, length = 50)
    private String series;

    @NotBlank(message = "Model name cannot be blank")
    @Column(name = "model_name", nullable = false, length = 100, unique = true) 
    private String modelName;

    @NotNull(message = "Base clock frequency cannot be null")
    @Column(name = "base_clock_ghz", nullable = false, precision = 3, scale = 2) 
    private BigDecimal baseClockGhz;

    @Column(name = "boost_clock_ghz", precision = 3, scale = 2)
    private BigDecimal boostClockGhz;

    @NotNull(message = "Core count cannot be null")
    @Column(name = "core_count", nullable = false)
    private Integer coreCount;

    @NotNull(message = "Thread count cannot be null")
    @Column(name = "thread_count", nullable = false)
    private Integer threadCount;

    @NotNull(message = "Cache size cannot be null")
    @Column(name = "cache_mb", nullable = false)
    private Integer cacheMb;
}