package com.laptopdb.backend.controllers;

import java.net.URI;
import java.util.List;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.laptopdb.backend.dto.GpuResponse;
import com.laptopdb.backend.dto.PagedResponse;
import com.laptopdb.backend.entity.Gpu;
import com.laptopdb.backend.services.GpuService;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Validated
@RestController
@RequestMapping("/api/v1/gpus")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GpuController {

    private final GpuService gpuService;

    @GetMapping
    public ResponseEntity<PagedResponse<GpuResponse>> getAll(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("desc") ? Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        return ResponseEntity.ok(PagedResponse.of(gpuService.findAll(PageRequest.of(page, size, sort))));
    }

    @GetMapping("/all")
    public ResponseEntity<List<GpuResponse>> getAllList() {
        return ResponseEntity.ok(gpuService.findAllList());
    }

    @GetMapping("/{id}")
    public ResponseEntity<GpuResponse> getById(@PathVariable @Min(1) Integer id) {
        return ResponseEntity.ok(gpuService.getById(id));
    }

    @PostMapping
    public ResponseEntity<GpuResponse> create(@Valid @RequestBody Gpu gpu) {
        GpuResponse created = gpuService.create(gpu);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest().path("/{id}")
                .buildAndExpand(created.getId()).toUri();
        return ResponseEntity.created(location).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<GpuResponse> update(@PathVariable @Min(1) Integer id, @Valid @RequestBody Gpu gpu) {
        return ResponseEntity.ok(gpuService.update(id, gpu));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable @Min(1) Integer id) {
        gpuService.delete(id);
        return ResponseEntity.noContent().build();
    }
}