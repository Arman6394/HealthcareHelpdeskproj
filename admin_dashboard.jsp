<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // Security Check: Only allow 'admin'
    String user = (String) session.getAttribute("user");
    if(user == null || !user.equals("admin")) { 
        response.sendRedirect("index.html");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Portal</title>
   <style>
    /* 1. MODERN BACKGROUND & FONT */
    body { 
        font-family: 'Poppins', 'Segoe UI', sans-serif; 
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); /* Soft Blue Gradient */
        padding: 20px; 
        margin: 0;
        min-height: 100vh;
    }

    /* 2. STYLISH HEADER (Gradient) */
    .header { 
        background: linear-gradient(to right, #434343 0%, black 100%); /* Electric Blue Gradient */
        color: white; 
        padding: 15px 25px; 
        border-radius: 15px; 
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1); 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
        margin-bottom: 25px;
    }
    
    /* 3. CARDS (Glass Effect & Float Animation) */
    .card { 
        background: white; 
        padding: 25px; 
        border-radius: 15px; 
        box-shadow: 0 5px 15px rgba(0,0,0,0.05); 
        flex: 1; 
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        border: 1px solid rgba(255,255,255,0.5);
    }
    .card:hover {
        transform: translateY(-5px); /* Upar uthne ka effect */
        box-shadow: 0 15px 30px rgba(0,0,0,0.1);
    }
    
    /* 4. MODERN INPUTS */
    input, select, textarea { 
        width: 100%; 
        padding: 12px; 
        margin: 10px 0; 
        border: 2px solid #e0e0e0; 
        border-radius: 8px; 
        box-sizing: border-box;
        font-size: 14px;
        transition: border-color 0.3s;
    }
    input:focus, select:focus, textarea:focus {
        border-color: #4facfe; /* Focus karne par Blue border */
        outline: none;
    }

    /* 5. SUPER STYLISH BUTTONS (Gradient & Glow) */
    button { 
        width: 100%; 
        padding: 12px; 
        background: linear-gradient(45deg, #43e97b 0%, #38f9d7 100%); /* Green-Blue Gradient */
        color: white; 
        border: none; 
        border-radius: 25px; /* Round Buttons */
        cursor: pointer; 
        font-weight: bold;
        font-size: 15px;
        text-transform: uppercase;
        letter-spacing: 1px;
        box-shadow: 0 5px 15px rgba(56, 249, 215, 0.4);
        transition: all 0.3s ease;
    }
    button:hover { 
        transform: scale(1.02); /* Thoda bada hoga */
        box-shadow: 0 8px 20px rgba(56, 249, 215, 0.6);
    }
    
    /* Special Red Button (Complaint) */
    button[type="submit"][style*="dc3545"] {
        background: linear-gradient(45deg, #ff9a9e 0%, #fecfef 99%, #fecfef 100%);
        background: linear-gradient(to right, #ff416c, #ff4b2b); /* Red Gradient */
        box-shadow: 0 5px 15px rgba(255, 75, 43, 0.4);
    }

    /* 6. BEAUTIFUL TABLE */
    table { 
        width: 100%; 
        border-collapse: separate; 
        border-spacing: 0;
        background: white; 
        border-radius: 12px; 
        overflow: hidden; 
        box-shadow: 0 4px 10px rgba(0,0,0,0.05); 
    }
    th { 
        background-color: #f8f9fa; 
        color: #333; 
        font-weight: 700;
        text-transform: uppercase;
        font-size: 13px;
        padding: 15px;
        border-bottom: 2px solid #eee;
    }
    td { 
        padding: 15px; 
        border-bottom: 1px solid #eee;
        color: #555;
    }
    tr:hover td {
        background-color: #f9fbfd; /* Row highlight effect */
    }

    /* 7. STATUS BADGES (Chote Capsule jaise) */
    .status-Pending, .Pending { 
        background: #fff3cd; color: #856404; padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: bold;
    }
    .status-Confirmed, .Confirmed { 
        background: #d4edda; color: #155724; padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: bold;
    }
    .status-Rejected, .Rejected { 
        background: #f8d7da; color: #721c24; padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: bold;
    }

    /* 8. LAYOUT UTILITIES */
    .container { display: flex; flex-direction: column; gap: 25px; margin-top: 25px; }
    .row { display: flex; gap: 25px; flex-wrap: wrap; }
    
    /* Price Field Special Look */
    #feeField { background-color: #f1f3f5; color: #333; font-weight: 800; border: none; }

    /* --- CHATBOX FIX --- */
    .chat-box { z-index: 9999; border-radius: 12px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
    .chat-header { background: linear-gradient(to right, #00c6ff, #0072ff); }
</style>
</head>
<body>

    <div class="header">
        <h2>🏥 Hospital Admin Console</h2>
        <div>
            <span>Logged in as: <b>ADMIN</b></span> | 
            <a href="LogoutServlet" class="btn logout">Logout</a>
        </div>
    </div>

    <!-- ========================================= -->
    <!-- SECTION 1: APPOINTMENTS MANAGEMENT        -->
    <!-- ========================================= -->
    <div class="search-container">
        <h3 style="color: #333; display:inline-block; margin-right: 20px;">📅 Appointment Requests</h3>
        <input type="text" id="searchInput" onkeyup="filterTable()" class="search-box" placeholder="🔍 Search patient, doctor...">
    </div>

    <table id="apptTable">
        <thead>
            <tr>
                <th>ID</th>
                <th>Patient Name</th>
                <th>Doctor</th>
                <th>Date</th>
                <th>Fee</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% 
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    // ⚠️ UPDATE PASSWORD 1 ⚠️
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/healthcare_db", "root", "Arman@2406");
                    
                    PreparedStatement pst = conn.prepareStatement("SELECT * FROM appointments ORDER BY FIELD(status, 'Pending', 'Confirmed', 'Rejected'), appt_date DESC");
                    ResultSet rs = pst.executeQuery();

                    while(rs.next()) {
                        int id = rs.getInt("id");
                        String status = rs.getString("status");
            %>
            <tr>
                <td>#<%= id %></td>
                <td><%= rs.getString("username") %></td>
                <td><%= rs.getString("doctor_name") %></td>
                <td><%= rs.getDate("appt_date") %></td>
                <td>₹<%= rs.getInt("consultation_fee") %></td>
                <td class="<%= status %>"><%= status %></td>
                <td>
                    <% if(status.equals("Pending")) { %>
                        <a href="UpdateStatusServlet?id=<%=id%>&status=Confirmed" class="btn approve">Approve</a>
                        <a href="UpdateStatusServlet?id=<%=id%>&status=Rejected" class="btn reject">Reject</a>
                    <% } else { %>
                        <span style="color: #888;">Locked</span>
                    <% } %>
                </td>
            </tr>
            <% 
                    }
                    conn.close();
                } catch(Exception e) {
                    out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
                }
            %>
        </tbody>
    </table>

    <br><hr style="border-top: 1px solid #ccc;"><br>

    <!-- ========================================= -->
    <!-- SECTION 2: COMPLAINTS / TICKETS           -->
    <!-- ========================================= -->
    <h3 style="color: #dc3545;">🚨 Support Tickets & Complaints</h3>

    <table>
        <thead>
            <tr style="background-color: #dc3545;"> <!-- Red Header for Complaints -->
                <th style="background-color: #dc3545;">Ticket ID</th>
                <th style="background-color: #dc3545;">User</th>
                <th style="background-color: #dc3545;">Category</th>
                <th style="background-color: #dc3545;">Description</th>
                <th style="background-color: #dc3545;">Status</th>
                <th style="background-color: #dc3545;">Action</th>
            </tr>
        </thead>
        <tbody>
            <% 
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    // ⚠️ UPDATE PASSWORD 2 ⚠️ (Make sure to update this one too!)
                    Connection conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/healthcare_db", "root", "Arman@2406");
                    
                    // Fetch Complaints (Open tickets first)
                    PreparedStatement pst2 = conn2.prepareStatement("SELECT * FROM complaints ORDER BY status DESC, created_at DESC");
                    ResultSet rs2 = pst2.executeQuery();

                    while(rs2.next()) {
                        int cid = rs2.getInt("id");
                        String cStatus = rs2.getString("status");
            %>
            <tr>
                <td>#<%= cid %></td>
                <td><%= rs2.getString("username") %></td>
                <td><b><%= rs2.getString("category") %></b></td>
                <td><%= rs2.getString("description") %></td>
                
                <td class="<%= cStatus %>"><%= cStatus %></td>
                
                <td>
                    <% if(cStatus.equals("Open")) { %>
                        <a href="ResolveComplaintServlet?id=<%= cid %>" class="btn resolve">Mark Resolved</a>
                    <% } else { %>
                        <span style="color: grey;">Closed</span>
                    <% } %>
                </td>
            </tr>
            <% 
                    }
                    conn2.close(); 
                } catch(Exception e) {
                    out.println("<tr><td colspan='6'>Error loading complaints: " + e.getMessage() + "</td></tr>");
                }
            %>
        </tbody>
    </table>
    
    <br><br><br>

    <!-- JavaScript for Search Filter -->
    <script>
        function filterTable() {
            var input = document.getElementById("searchInput");
            var filter = input.value.toUpperCase();
            var table = document.getElementById("apptTable");
            var tr = table.getElementsByTagName("tr");
            for (var i = 1; i < tr.length; i++) {
                var tdUser = tr[i].getElementsByTagName("td")[1];
                var tdDoc = tr[i].getElementsByTagName("td")[2];
                var tdStatus = tr[i].getElementsByTagName("td")[5];
                if (tdUser || tdDoc || tdStatus) {
                    var txtUser = tdUser.textContent || tdUser.innerText;
                    var txtDoc = tdDoc.textContent || tdDoc.innerText;
                    var txtStatus = tdStatus.textContent || tdStatus.innerText;
                    if (txtUser.toUpperCase().indexOf(filter) > -1 || txtDoc.toUpperCase().indexOf(filter) > -1 || txtStatus.toUpperCase().indexOf(filter) > -1) {
                        tr[i].style.display = "";
                    } else {
                        tr[i].style.display = "none";
                    }
                }       
            }
        }
    </script>
</body>
</html>