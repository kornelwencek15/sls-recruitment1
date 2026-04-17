package pl.slsolutions.devopstest;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

@RestController
public class VisitorController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/")
    public String hello() {
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS visits (id SERIAL, ts TIMESTAMP)");
        jdbcTemplate.execute("INSERT INTO visits (ts) VALUES (NOW())");
        Long count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM visits", Long.class);

        return "Hello DevOps! Total visits: " + count;
    }

    @GetMapping("/health")
    public String health() {
        return "UP";
    }
}

