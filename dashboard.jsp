<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // Security Check
    String user = (String) session.getAttribute("user");
    if(user == null) {
        response.sendRedirect("index.html");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Patient Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    
    <style>
        /* ============================
           1. MODERN BODY & LAYOUT
           ============================ */
        body { 
            font-family: 'Poppins', sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); 
            padding: 20px; 
            min-height: 100vh; 
            margin: 0;
        }
        
        /* ============================
           2. STYLISH HEADER
           ============================ */
        .header { 
            background: linear-gradient(to right, #4facfe 0%, #00f2fe 100%); /* Electric Blue Gradient */
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

        .btn-doctors {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            font-weight: 600;
            padding: 8px 15px;
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.4);
            transition: all 0.3s;
        }
        .btn-doctors:hover { background: white; color: #007bff; }

        .btn-logout {
            background: #ff6b6b;
            color: white;
            text-decoration: none;
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: bold;
            box-shadow: 0 4px 10px rgba(255, 107, 107, 0.4);
            transition: transform 0.2s;
        }
        .btn-logout:hover { transform: scale(1.05); }

        /* ============================
           3. CARDS & CONTAINERS
           ============================ */
        .container { display: flex; flex-direction: column; gap: 30px; }
        .row { display: flex; gap: 30px; flex-wrap: wrap; }
        
        .card { 
            background: white; 
            padding: 30px; 
            border-radius: 20px; 
            box-shadow: 0 10px 25px rgba(0,0,0,0.05); 
            flex: 1; 
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            border: 1px solid rgba(255,255,255,0.8);
        }
        .card:hover { 
            transform: translateY(-5px); 
            box-shadow: 0 15px 30px rgba(0,0,0,0.1); 
        }

        h3 { margin-top: 0; font-weight: 700; font-size: 18px; display: flex; align-items: center; gap: 10px; }

        /* ============================
           4. FORMS & INPUTS
           ============================ */
        label { font-size: 13px; font-weight: 600; color: #555; margin-top: 10px; display: block; }
        
        input, select, textarea { 
            width: 100%; padding: 12px; margin: 5px 0 15px 0; 
            border: 2px solid #f0f2f5; border-radius: 10px; 
            box-sizing: border-box; font-family: 'Poppins', sans-serif; font-size: 14px;
            background: #f9fbfd;
            transition: 0.3s;
        }
        input:focus, select:focus, textarea:focus { 
            border-color: #4facfe; outline: none; background: white; 
        }

        #feeField { background: #eef2f7; color: #333; font-weight: 800; border: none; }

        /* ============================
           5. BUTTONS (GRADIENT)
           ============================ */
        .btn-submit { 
            width: 100%; padding: 12px; 
            background: linear-gradient(to right, #0062cc, #007bff); 
            color: white; border: none; border-radius: 12px; 
            cursor: pointer; font-weight: bold; margin-top: 10px;
            box-shadow: 0 5px 15px rgba(0, 123, 255, 0.3);
            transition: transform 0.2s;
        }
        .btn-submit:hover { transform: translateY(-2px); }

        .btn-complain {
            background: linear-gradient(to right, #ff416c, #ff4b2b);
            box-shadow: 0 5px 15px rgba(255, 75, 43, 0.3);
        }

        .btn-download {
            background: linear-gradient(to right, #11998e, #38ef7d); /* Green Gradient */
            color: white; padding: 8px 15px; border-radius: 20px; font-size: 12px; width: auto; 
            border: none; cursor: pointer; font-weight: 600;
            box-shadow: 0 4px 10px rgba(56, 239, 125, 0.3);
        }

        /* ============================
           6. TABLE STYLING
           ============================ */
        table { width: 100%; border-collapse: separate; border-spacing: 0; border-radius: 12px; overflow: hidden; }
        th { background: #f1f3f5; padding: 15px; text-align: left; font-weight: 700; color: #444; font-size: 13px; text-transform: uppercase; }
        td { padding: 15px; border-bottom: 1px solid #f1f1f1; color: #555; font-size: 14px; }
        tr:hover td { background: #f8f9fa; }
        
        /* Status Badges */
        .status-Pending { background: #fff8e1; color: #f57f17; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }
        .status-Confirmed { background: #e8f5e9; color: #2e7d32; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }
        .status-Rejected { background: #ffebee; color: #c62828; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }

        /* ============================
           7. CHATBOX (FIXED)
           ============================ */
        .chat-box {
            position: fixed; bottom: 20px; right: 20px; width: 320px;
            background: white; border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden; z-index: 9999;
            font-family: 'Poppins', sans-serif;
            border: none;
        }
        .chat-header { background: linear-gradient(to right, #00c6ff, #0072ff); color: white; padding: 15px; font-weight: bold; cursor: pointer; display: flex; justify-content: space-between; }
        .chat-content { height: 280px; padding: 15px; overflow-y: auto; background: #f4f7f6; }
        .chat-input-area { display: flex; padding: 10px; background: white; border-top: 1px solid #eee; }
        .chat-input-area input { margin: 0; border-radius: 20px; padding: 10px 15px; background: #f0f2f5; border:none; pointer-events: auto !important; z-index: 10000; }
        .chat-input-area button { width: auto; background: none; color: #007bff; padding: 0 15px; font-weight: bold; margin: 0; box-shadow: none; }
    </style>
</head>
<body>

    <div class="header">
        <h2>🏥 HealthDesk</h2>
        <div style="display: flex; align-items: center; gap: 15px;">
            <a href="doctors.jsp" class="btn-doctors">👨‍⚕️ View Specialists</a>
            <span>Hello, <b><%= user %></b></span>
            <a href="LogoutServlet" class="btn-logout">Logout</a>
        </div>
    </div>

    <div class="container">
        
        <div class="row">
            <div class="card">
                <h3 style="color:#007bff;">📅 Book Appointment</h3>
                <form action="BookAppointmentServlet" method="post">
                    <label>Select Doctor</label>
                    <select name="doctor" id="doctorSelect" onchange="updatePrice()" required>
                        <option value="" disabled selected>-- Choose Specialist --</option>
                        <option value="Dr. Sharma (Cardiologist)">Dr. Sharma (Cardiologist)</option>
                        <option value="Dr. Verma (Dentist)">Dr. Verma (Dentist)</option>
                        <option value="Dr. Iyer (General Physician)">Dr. Iyer (General Physician)</option>
                        <option value="Dr. Singh (Neurologist)">Dr. Singh (Neurologist)</option>
                    </select>

                    <div style="display: flex; gap: 10px;">
                        <div style="flex:1">
                            <label>Consultation Fee</label>
                            <input type="text" name="fee" id="feeField" readonly value="₹0">
                        </div>
                        <div style="flex:1">
                            <label>Preferred Date</label>
                            <input type="date" name="date" required>
                        </div>
                    </div>

                    <label>Problem Description</label>
                    <input type="text" name="problem" placeholder="e.g. High fever since yesterday..." required>

                    <button type="submit" class="btn-submit">Confirm Booking</button>
                </form>
            </div>

            <div class="card" style="flex: 2;">
                <h3 style="color:#2d3436;">📜 My History</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Doctor</th>
                            <th>Date</th>
                            <th>Status</th>
                            <th>Report</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                // ⚠️ UPDATE PASSWORD HERE ⚠️
                                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/healthcare_db", "root", "Arman@2406");
                                
                                PreparedStatement pst = conn.prepareStatement("SELECT * FROM appointments WHERE username=? ORDER BY appt_date DESC");
                                pst.setString(1, user);
                                ResultSet rs = pst.executeQuery();

                                while(rs.next()) {
                        %>
                        <tr>
                            <td>
                                <b><%= rs.getString("doctor_name") %></b><br>
                                <span style="font-size:12px; color:#888;">Fee: ₹<%= rs.getInt("consultation_fee") %></span>
                            </td>
                            <td><%= rs.getDate("appt_date") %></td>
                            <td><span class="status-<%= rs.getString("status") %>"><%= rs.getString("status") %></span></td>
                            
                            <td>
                                <% if(rs.getString("prescription") != null && !rs.getString("prescription").isEmpty()) { %>
                                    <button onclick="printReport('<%= rs.getString("doctor_name") %>', '<%= rs.getDate("appt_date") %>', '<%= rs.getString("prescription") %>', '<%= user %>')" 
                                            class="btn-download">
                                        ⬇ PDF
                                    </button>
                                <% } else { %>
                                    <span style="color: #ccc; font-size: 12px;">Waiting...</span>
                                <% } %>
                            </td>
                        </tr>
                        <% 
                                }
                                conn.close();
                            } catch(Exception e) {
                                out.println("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card" style="border-left: 5px solid #ff4b2b;">
            <h3 style="color: #ff4b2b;">⚠️ Raise a Ticket</h3>
            <form action="SubmitComplaintServlet" method="post" style="display:flex; gap:15px; align-items:flex-end;">
                <div style="flex:1;">
                    <label>Category</label>
                    <select name="category" required style="margin:0;">
                        <option value="Billing Issue">Billing Issue</option>
                        <option value="Appointment Issue">Appointment Delay</option>
                        <option value="Medical Record">Medical Record</option>
                        <option value="Staff Behavior">Staff Behavior</option>
                    </select>
                </div>
                <div style="flex:3;">
                    <label>Description</label>
                    <input type="text" name="description" placeholder="Describe your issue..." required style="margin:0;">
                </div>
                <button type="submit" class="btn-submit btn-complain" style="width:auto; margin:0;">Submit</button>
            </form>
        </div>

    </div> 

    <div class="chat-box" id="chatWindow">
        <div class="chat-header" onclick="toggleChat()">
            <span>💬 Live Support</span>
            <span style="font-size:12px;">▼</span>
        </div>
        <div class="chat-content" id="chatContent">
            <p style="text-align:center; color:#888; font-size:12px; margin-top:50px;">Connecting to staff...</p>
        </div>
        <div class="chat-input-area">
            <input type="text" id="msgInput" placeholder="Type message...">
            <button onclick="sendMessage()">➤</button>
        </div>
    </div>

    <script>
        // 1. PRICE LOGIC
        function updatePrice() {
            var prices = { "Dr. Sharma (Cardiologist)": 1500, "Dr. Verma (Dentist)": 800, "Dr. Iyer (General Physician)": 500, "Dr. Singh (Neurologist)": 2000 };
            var doctor = document.getElementById("doctorSelect").value;
            var feeField = document.getElementById("feeField");
            if (prices[doctor]) feeField.value = "₹" + prices[doctor];
            else feeField.value = "₹0";
        }

        // 2. PRINT REPORT LOGIC
        function printReport(doctor, date, meds, patient) {
            var printWindow = window.open('', '', 'height=600,width=800');
            printWindow.document.write('<html><head><title>Medical Report</title>');
            printWindow.document.write('<style>body{font-family: "Segoe UI", sans-serif; padding: 40px; color:#333;} .header{text-align:center; border-bottom:3px solid #007bff; padding-bottom:20px; margin-bottom:30px;} .logo{color:#007bff; font-size:28px; font-weight:bold; text-transform:uppercase;} .info{margin-bottom:30px; line-height:1.6; font-size:14px;} .rx{border:2px solid #eee; padding:25px; border-radius:15px; background:#f8f9fa; font-size:18px; font-weight:500;} .footer{margin-top:50px; text-align:right; font-style:italic;} </style>');
            printWindow.document.write('</head><body>');
            printWindow.document.write('<div class="header"><div class="logo">🏥 HealthDesk Hospital</div><p>Science City Road, Tech Park | www.healthdesk.com</p></div>');
            printWindow.document.write('<div class="info"><table style="width:100%"><tr><td><strong>Patient:</strong> ' + patient.toUpperCase() + '</td><td style="text-align:right"><strong>Date:</strong> ' + date + '</td></tr><tr><td><strong>Doctor:</strong> ' + doctor + '</td><td style="text-align:right"><strong>Case ID:</strong> #RES-' + Math.floor(Math.random() * 10000) + '</td></tr></table></div>');
            printWindow.document.write('<h3>💊 Diagnosis & Prescription</h3><div class="rx"><p>' + meds + '</p></div>');
            printWindow.document.write('<div class="footer"><p>Digitally Signed by<br><b>' + doctor + '</b></p></div>');
            printWindow.document.write('</body></html>');
            printWindow.document.close();
            printWindow.print();
        }

        // 3. CHAT LOGIC
        var currentUser = "<%= user %>"; 
        function sendMessage() {
            var msg = document.getElementById("msgInput").value;
            if(msg.trim() === "") return;
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "ChatServlet", true);
            xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhr.send("user=" + currentUser + "&message=" + msg);
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
        setInterval(fetchMessages, 2000); 

        var isOpen = true;
        function toggleChat() {
            var content = document.getElementById("chatContent");
            var input = document.querySelector(".chat-input-area");
            if(isOpen) { content.style.display = "none"; input.style.display = "none"; } 
            else { content.style.display = "block"; input.style.display = "flex"; }
            isOpen = !isOpen;
        }
    </script>

</body>
</html>