<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // Security Check: Only allow 'staff' or 'nurse'
    String user = (String) session.getAttribute("user");
    if(user == null || (!user.equals("staff") && !user.equals("nurse"))) { 
        response.sendRedirect("index.html");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Staff Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    
    <style>
        /* ============================
           1. PURPLE THEME & LAYOUT
           ============================ */
        body { 
            font-family: 'Poppins', sans-serif; 
            /* Soft Purple Gradient Background */
            background: linear-gradient(135deg, #f3e5f5 0%, #e1bee7 100%); 
            padding: 20px; 
            min-height: 100vh; 
            margin: 0;
        }
        
        /* ============================
           2. STYLISH HEADER
           ============================ */
        .header { 
            /* Deep Purple Gradient */
            background: linear-gradient(to right, #8e2de2, #4a00e0); 
            padding: 15px 30px; 
            border-radius: 15px; 
            box-shadow: 0 10px 20px rgba(0,0,0,0.1); 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            color: white;
            margin-bottom: 30px;
        }
        
        .header h2 { margin: 0; font-weight: 700; letter-spacing: 1px; }

        .btn-logout {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: bold;
            border: 1px solid rgba(255,255,255,0.5);
            transition: transform 0.2s;
        }
        .btn-logout:hover { background: white; color: #4a00e0; }

        h3 { color: #4a148c; font-weight: 700; margin-top: 30px; }

        /* ============================
           3. MODERN TABLES
           ============================ */
        table { 
            width: 100%; 
            border-collapse: separate; 
            border-spacing: 0; 
            background: white; 
            border-radius: 15px; 
            overflow: hidden; 
            box-shadow: 0 5px 15px rgba(0,0,0,0.05); 
            margin-top: 10px; 
        }
        
        th { 
            background: #ab47bc; /* Purple Header */
            color: white; 
            padding: 15px; 
            text-align: left; 
            font-weight: 600; 
            text-transform: uppercase;
            font-size: 13px;
        }
        
        td { padding: 15px; border-bottom: 1px solid #f3e5f5; color: #444; font-size: 14px; }
        tr:hover td { background: #fce4ec; } /* Light pink hover effect */

        /* ============================
           4. ACTION BUTTONS
           ============================ */
        .btn { padding: 6px 15px; border: none; border-radius: 20px; cursor: pointer; color: white; text-decoration: none; font-size: 11px; font-weight: bold; margin-right: 5px; box-shadow: 0 3px 6px rgba(0,0,0,0.1); }
        .approve { background: linear-gradient(to right, #11998e, #38ef7d); } 
        .reject { background: linear-gradient(to right, #ff416c, #ff4b2b); }  
        .resolve { background: linear-gradient(to right, #00b09b, #96c93d); }
        .view { background: #00bcd4; }

        /* PRESCRIPTION FORM STYLE */
        .rx-form { display: flex; gap: 5px; }
        .rx-input { border: 1px solid #ddd; padding: 5px; border-radius: 5px; font-size: 12px; width: 150px; outline: none; }
        .rx-btn { background: #6a1b9a; color: white; border: none; padding: 5px 10px; border-radius: 5px; cursor: pointer; font-size: 11px; font-weight: bold; }

        /* STATUS BADGES */
        .status-Pending { background: #fff3cd; color: #856404; padding: 5px 10px; border-radius: 10px; font-size: 11px; font-weight: bold; }
        .status-Confirmed { background: #d4edda; color: #155724; padding: 5px 10px; border-radius: 10px; font-size: 11px; font-weight: bold; }
        .status-Rejected { background: #f8d7da; color: #721c24; padding: 5px 10px; border-radius: 10px; font-size: 11px; font-weight: bold; }

        /* ============================
           5. STAFF CHATBOX (PURPLE STYLE)
           ============================ */
        .chat-box {
            position: fixed; bottom: 20px; right: 20px; width: 320px;
            background: white; border-radius: 15px;
            border: 2px solid #8e2de2; /* Purple Border */
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden; z-index: 9999;
            font-family: 'Poppins', sans-serif;
        }
        .chat-header { 
            background: linear-gradient(to right, #8e2de2, #4a00e0); /* Purple Gradient */
            color: white; padding: 15px; font-weight: bold; cursor: pointer; display: flex; justify-content: space-between; 
        }
        .chat-content { height: 300px; padding: 15px; overflow-y: auto; background: #f3e5f5; }
        .chat-input-area { display: flex; padding: 10px; background: white; border-top: 1px solid #eee; }
        .chat-input-area input { margin: 0; border-radius: 20px; padding: 10px 15px; background: #f3e5f5; border:none; pointer-events: auto !important; z-index: 10000; flex: 1; outline:none; }
        .chat-input-area button { width: auto; background: #6a1b9a; color: white; padding: 0 15px; border-radius: 20px; font-weight: bold; margin-left: 5px; border:none; cursor: pointer; }

    </style>
</head>
<body>

    <div class="header">
        <h2>🏥 Staff Panel</h2>
        <div>
            <span>Operator: <b><%= user.toUpperCase() %></b></span> | 
            <a href="LogoutServlet" class="btn-logout">Logout</a>
        </div>
    </div>

    <h3>📅 Manage Appointments & Prescriptions</h3>
    
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Date</th>
                <th>Fee</th>
                <th>Status</th>
                <th>Action / Prescription</th>
            </tr>
        </thead>
        <tbody>
            <% 
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    // ⚠️ UPDATE PASSWORD HERE ⚠️
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
                <td><span class="status-<%= status %>"><%= status %></span></td>
                <td>
                    <% if(status.equals("Pending")) { %>
                        <a href="UpdateStatusServlet?id=<%=id%>&status=Confirmed" class="btn approve">Approve</a>
                        <a href="UpdateStatusServlet?id=<%=id%>&status=Rejected" class="btn reject">Reject</a>
                    
                    <% } else if(status.equals("Confirmed")) { %>
                        
                        <% if(rs.getString("prescription") == null) { %>
                            <form action="AddPrescriptionServlet" method="post" class="rx-form">
                                <input type="hidden" name="id" value="<%= id %>">
                                <input type="text" name="notes" placeholder="Meds/Diagnosis..." required class="rx-input">
                                <button type="submit" class="rx-btn">Add RX</button>
                            </form>
                        <% } else { %>
                            <span style="color: #4caf50; font-weight: bold; font-size: 13px;">Report Sent ✅</span>
                            <button onclick="printReport('<%= rs.getString("doctor_name") %>', '<%= rs.getDate("appt_date") %>', '<%= rs.getString("prescription") %>', '<%= rs.getString("username") %>')" class="btn view">
                                📄 View
                            </button>
                        <% } %>

                    <% } else { %>
                        <span style="color: #ccc;">Closed</span>
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

    <br>

    <h3 style="color: #d32f2f;">🚨 Patient Complaints</h3>
    
    <table>
        <thead>
            <tr style="background: #e57373;">
                <th style="background: #ef5350;">ID</th>
                <th style="background: #ef5350;">User</th>
                <th style="background: #ef5350;">Category</th>
                <th style="background: #ef5350;">Description</th>
                <th style="background: #ef5350;">Status</th>
                <th style="background: #ef5350;">Action</th>
            </tr>
        </thead>
        <tbody>
            <% 
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    // ⚠️ UPDATE PASSWORD HERE TOO ⚠️
                    Connection conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/healthcare_db", "root", "Arman@2406");
                    PreparedStatement pst2 = conn2.prepareStatement("SELECT * FROM complaints ORDER BY status DESC");
                    ResultSet rs2 = pst2.executeQuery();

                    while(rs2.next()) {
                        int cid = rs2.getInt("id");
                        String cStatus = rs2.getString("status");
            %>
            <tr>
                <td>#<%= cid %></td>
                <td><%= rs2.getString("username") %></td>
                <td><%= rs2.getString("category") %></td>
                <td><%= rs2.getString("description") %></td>
                <td style="color: <%= cStatus.equals("Open") ? "red" : "green" %>; font-weight:bold;"><%= cStatus %></td>
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
                } catch(Exception e) { out.println(e); }
            %>
        </tbody>
    </table>
    
    <br><br><br> <div class="chat-box" id="chatWindow">
        <div class="chat-header" onclick="toggleChat()">
            <span>👨‍💼 Staff Support Chat</span>
            <span style="font-size: 12px;">(Live)</span>
        </div>
        <div class="chat-content" id="chatContent">
            <p style="text-align:center; color:#888; margin-top:50px;">Waiting for patient messages...</p>
        </div>
        <div class="chat-input-area">
            <input type="text" id="msgInput" placeholder="Reply to patient...">
            <button onclick="sendMessage()">Reply</button>
        </div>
    </div>

    <script>
        // 1. CHAT LOGIC
        var currentUser = "<%= user %>"; 

        function sendMessage() {
            var msg = document.getElementById("msgInput").value;
            if(msg.trim() === "") return;
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "ChatServlet", true);
            xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            // Appends '(Staff)' so patient knows who is talking
            xhr.send("user=" + currentUser + " (Staff)&message=" + msg);
            document.getElementById("msgInput").value = ""; 
            fetchMessages(); 
        }

        function fetchMessages() {
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (this.readyState == 4 && this.status == 200) {
                    document.getElementById("chatContent").innerHTML = this.responseText;
                }
            };
            xhr.open("GET", "ChatServlet", true);
            xhr.send();
        }

        setInterval(fetchMessages, 2000); // Auto Refresh

        var isOpen = true;
        function toggleChat() {
            var content = document.getElementById("chatContent");
            var input = document.querySelector(".chat-input-area");
            if(isOpen) { content.style.display = "none"; input.style.display = "none"; }
            else { content.style.display = "block"; input.style.display = "flex"; }
            isOpen = !isOpen;
        }

        // 2. PRINT REPORT LOGIC (For View Button)
        function printReport(doctor, date, meds, patient) {
            var printWindow = window.open('', '', 'height=600,width=800');
            printWindow.document.write('<html><head><title>Medical Report</title>');
            printWindow.document.write('<style>body{font-family: sans-serif; padding: 40px; color:#333;} .header{text-align:center; border-bottom:3px solid #6a1b9a; padding-bottom:20px; margin-bottom:30px;} .logo{color:#6a1b9a; font-size:28px; font-weight:bold; text-transform:uppercase;} .info{margin-bottom:30px; line-height:1.6;} .rx{border:2px solid #eee; padding:25px; border-radius:15px; background:#f8f9fa; font-size:18px;} .footer{margin-top:50px; text-align:right; font-style:italic;} </style>');
            printWindow.document.write('</head><body>');
            printWindow.document.write('<div class="header"><div class="logo">🏥 HealthDesk Hospital</div><p>Staff Copy | Internal Record</p></div>');
            printWindow.document.write('<div class="info"><p><strong>Patient Name:</strong> ' + patient.toUpperCase() + '</p><p><strong>Doctor:</strong> ' + doctor + '</p><p><strong>Date:</strong> ' + date + '</p></div>');
            printWindow.document.write('<h3>💊 Diagnosis & Prescription</h3><div class="rx"><p>' + meds + '</p></div>');
            printWindow.document.write('<div class="footer"><p>Authorized by<br><b>' + doctor + '</b></p></div>');
            printWindow.document.write('</body></html>');
            printWindow.document.close();
            printWindow.print();
        }
    </script>

</body>
</html>