<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Our Doctors</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f4f7f6; padding: 20px; }
        .header { background: #007bff; color: white; padding: 15px; border-radius: 8px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn-back { background: white; color: #007bff; text-decoration: none; padding: 8px 15px; border-radius: 4px; font-weight: bold; }
        
        /* GRID LAYOUT FOR CARDS */
        .doctor-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); /* Responsive Grid */
            gap: 20px;
        }

        /* CARD DESIGN */
        .doc-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            overflow: hidden;
            text-align: center;
            transition: transform 0.2s;
        }
        .doc-card:hover { transform: translateY(-5px); } /* Hover Effect */

        .doc-img {
            width: 100px;
            height: 100px;
            margin-top: 20px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #007bff;
        }

        .doc-info { padding: 20px; }
        .doc-name { font-size: 1.2rem; color: #333; margin-bottom: 5px; }
        .doc-spec { color: #007bff; font-weight: bold; margin-bottom: 10px; }
        .doc-meta { font-size: 0.9rem; color: #666; margin-top: 5px; }
        
        .badge {
            background: #eef2f7;
            color: #555;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.8rem;
            display: inline-block;
            margin-top: 10px;
        }
    </style>
</head>
<body>

    <div class="header">
        <h2>👨‍⚕️ Meet Our Specialists</h2>
        <a href="dashboard.jsp" class="btn-back">← Back to Dashboard</a>
    </div>

    <div class="doctor-grid">
        <% 
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                // ⚠️ UPDATE PASSWORD HERE ⚠️
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/healthcare_db", "root", "Arman@2406");
                
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM doctors");

                while(rs.next()) {
        %>
        
        <div class="doc-card">
            <img src="<%= rs.getString("image_url") %>" alt="Doctor" class="doc-img">
            <div class="doc-info">
                <h3 class="doc-name"><%= rs.getString("name") %></h3>
                <div class="doc-spec"><%= rs.getString("specialization") %></div>
                
                <div class="doc-meta">
                    <strong>Qualification:</strong><br> <%= rs.getString("qualification") %>
                </div>
                
                <div class="badge">
                    <%= rs.getInt("experience") %>+ Years Experience
                </div>
            </div>
        </div>

        <% 
                }
                conn.close();
            } catch(Exception e) {
                out.println("<p>Error loading doctors: " + e.getMessage() + "</p>");
            }
        %>
    </div>

</body>
</html>