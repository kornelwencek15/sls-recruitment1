package pl.slsolutions.devopstest;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class VisitorControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testHealthEndpoint() throws Exception {
        mockMvc.perform(get("/health"))
                .andExpect(status().isOk())
                .andExpect(content().string("UP"));
    }

    @Test
    void testHelloEndpoint() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(content().string(containsString("Hello DevOps!")))
                .andExpect(content().string(containsString("Total visits:")));
    }

    @Test
    void testHelloEndpointReturnsVisitCount() throws Exception {
        // Wysyłamy żądanie i sprawdzamy, że serwer zwraca liczbę odwiedzin
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(content().string(containsString("Total visits:")));

        // Drugieżądanie
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(content().string(containsString("Total visits:")));
    }

    @Test
    void testMultipleVisits() throws Exception {
        // Test wielokrotnych odwiedzin
        for (int i = 0; i < 3; i++) {
            mockMvc.perform(get("/"))
                    .andExpect(status().isOk())
                    .andExpect(content().string(containsString("Hello DevOps!")));
        }
    }
}

