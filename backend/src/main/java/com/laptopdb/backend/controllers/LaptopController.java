package com.laptopdb.backend.controllers;

import java.net.URI;
import java.util.List; 
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.laptopdb.backend.dto.LaptopFilterRequest;
import com.laptopdb.backend.dto.LaptopRequest;
import com.laptopdb.backend.dto.LaptopResponse;
import com.laptopdb.backend.dto.PagedResponse;
import com.laptopdb.backend.services.LaptopService;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Validated
@RestController
@RequestMapping("/api/v1/laptops")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LaptopController {

    private final LaptopService laptopService;

    @GetMapping
    public ResponseEntity<PagedResponse<LaptopResponse>> getAll(
            @ModelAttribute LaptopFilterRequest filter,
            @RequestParam(defaultValue = "0") @Min(value = 0, message = "page must be >= 0") int page,
            @RequestParam(defaultValue = "20") @Min(value = 1, message = "size must be >= 1") @Max(value = 100, message = "size must be <= 100") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {

        log.info("GET /api/v1/laptops — page={}, size={}, sortBy={}, sortDir={}, filter={}", page, size, sortBy, sortDir, filter);

        Sort sort = sortDir.equalsIgnoreCase("desc")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Page<LaptopResponse> resultPage = laptopService.findAll(filter, PageRequest.of(page, size, sort));

        return ResponseEntity.ok(PagedResponse.of(resultPage));
    }

    @GetMapping("/{id}")
    public ResponseEntity<LaptopResponse> getById(
            @PathVariable @Min(value = 1, message = "id must be >= 1") Integer id) {
        log.info("GET /api/v1/laptops/{}", id);
        return ResponseEntity.ok(laptopService.getById(id));
    }

    @PostMapping
    public ResponseEntity<LaptopResponse> create(@Valid @RequestBody LaptopRequest request) { // DEĞİŞTİ
        log.info("POST /api/v1/laptops — brand={}, series={}", request.getBrand(), request.getSeries());
        LaptopResponse created = laptopService.create(request);

        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(created.getId())
                .toUri();

        return ResponseEntity.created(location).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<LaptopResponse> update(
            @PathVariable @Min(value = 1, message = "id must be >= 1") Integer id,
            @Valid @RequestBody LaptopRequest request) { // DEĞİŞTİ
        log.info("PUT /api/v1/laptops/{}", id);
        return ResponseEntity.ok(laptopService.update(id, request));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<LaptopResponse> patch(
            @PathVariable @Min(value = 1, message = "id must be >= 1") Integer id,
            @RequestBody Map<String, Object> fields) {
        log.info("PATCH /api/v1/laptops/{} — fields: {}", id, fields.keySet());
        return ResponseEntity.ok(laptopService.patch(id, fields));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable @Min(value = 1, message = "id must be >= 1") Integer id) {
        log.info("DELETE /api/v1/laptops/{}", id);
        laptopService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/meta/brands")
    public ResponseEntity<List<String>> getBrands() {
        log.debug("GET /api/v1/laptops/meta/brands");
        return ResponseEntity.ok(laptopService.getDistinctBrands());
    }

    @GetMapping("/meta/gpu-models")
    public ResponseEntity<List<String>> getGpuModels() {
        log.debug("GET /api/v1/laptops/meta/gpu-models");
        return ResponseEntity.ok(laptopService.getDistinctGpuModels());
    }
}