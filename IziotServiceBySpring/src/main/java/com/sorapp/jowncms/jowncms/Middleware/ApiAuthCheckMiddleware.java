package com.sorapp.jowncms.jowncms.Middleware;

import com.sorapp.jowncms.jowncms.Function.Encript.EncriptService;
import com.sorapp.jowncms.jowncms.Models.Database.users_tbl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class ApiAuthCheckMiddleware implements HandlerInterceptor {

    private static final Logger LOGGER = LoggerFactory.getLogger(ApiAuthCheckMiddleware.class);

    @Autowired
    private EncriptService encription;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws IOException {
        // 1. اجازه عبور درخواست‌های OPTIONS (برای CORS)
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return true;
        }

        // 2. گرفتن هدر Authorization
        String authHeader = request.getHeader("Authorization");
        LOGGER.info("API Interceptor - URI: {}, Auth: {}", request.getRequestURI(), authHeader);

        // 3. اگر هدر وجود نداشت، خطای ۴۰۱ برگردان
        if (authHeader == null || authHeader.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Missing Authorization header\"}");
            return false;
        }

        // 4. دیکریپت و احراز هویت
        try {
            String json = encription.DEC(authHeader);
            users_tbl user = new users_tbl().FromJson(json);
            // (اختیاری) بررسی وجود کاربر در دیتابیس
            request.setAttribute("authenticatedUser", user);
            return true;
        } catch (Exception e) {
            LOGGER.error("Authentication failed", e);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Invalid token\"}");
            return false;
        }
    }
}