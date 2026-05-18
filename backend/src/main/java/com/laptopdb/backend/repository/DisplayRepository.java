package com.laptopdb.backend.repository;

import com.laptopdb.backend.entity.Display;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DisplayRepository extends JpaRepository<Display, Integer> {
}
