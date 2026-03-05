// services/emailService.js
const nodemailer = require('nodemailer');

const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

const sendEmailOTP = async (email, otp) => {
  try {
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS.replace(/\s+/g, '')
      },
      tls: {
        rejectUnauthorized: false
      }
    });
    
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'ایگری ویژن - تصدیقی کوڈ',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            @import url('https://fonts.googleapis.com/css2?family=Noto+Naskh+Arabic:wght@400;500;600;700&display=swap');
            * {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
            }
            body {
              font-family: 'Noto Naskh Arabic', Tahoma, Geneva, Verdana, sans-serif;
              background-color: #f8f9fa;
              line-height: 1.6;
              direction: rtl;
              text-align: right;
            }
            .container {
              max-width: 600px;
              margin: 0 auto;
              background-color: #ffffff;
            }
            .header {
              background: linear-gradient(135deg, #02A96C 0%, #00C853 100%);
              padding: 25px 20px;
              text-align: center;
              border-bottom: 4px solid #028c5a;
            }
            .header h1 {
              color: white;
              font-size: 36px;
              font-weight: 700;
              margin-bottom: 8px;
              text-shadow: 1px 1px 3px rgba(0,0,0,0.2);
            }
            .header p {
              color: rgba(255,255,255,0.95);
              font-size: 18px;
              margin: 0;
            }
            .content {
              padding: 30px;
            }
            .title {
              color: #02A96C;
              text-align: center;
              font-size: 26px;
              font-weight: 700;
              margin-bottom: 25px;
              padding-bottom: 15px;
              border-bottom: 2px solid #f0f0f0;
            }
            .message {
              margin-bottom: 25px;
            }
            .message p {
              color: #333;
              font-size: 18px;
              margin-bottom: 15px;
            }
            .otp-box {
              background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
              border-radius: 15px;
              padding: 30px;
              margin: 30px 0;
              text-align: center;
              border: 3px dashed #02A96C;
              box-shadow: 0 4px 15px rgba(2, 169, 108, 0.1);
            }
            .otp-label {
              color: #666;
              font-size: 18px;
              margin-bottom: 20px;
              font-weight: 600;
            }
            .otp-code {
              font-family: 'Courier New', monospace;
              font-size: 64px;
              font-weight: 900;
              color: #02A96C;
              letter-spacing: 20px;
              margin: 20px 0;
              padding: 15px;
              background: white;
              border-radius: 10px;
              display: inline-block;
              box-shadow: 0 3px 10px rgba(0,0,0,0.1);
              direction: ltr;
              text-align: center;
              min-width: 350px;
            }
            .otp-instruction {
              color: #666;
              font-size: 16px;
              margin-top: 20px;
              font-weight: 500;
            }
            .instructions-box {
              background-color: #e8f5e9;
              border-radius: 12px;
              padding: 25px;
              margin: 30px 0;
              border-right: 5px solid #2e7d32;
            }
            .instructions-title {
              color: #2e7d32;
              font-size: 20px;
              font-weight: 700;
              margin-bottom: 15px;
            }
            .instructions-list {
              list-style-type: none;
              padding-right: 0;
            }
            .instructions-list li {
              color: #333;
              font-size: 17px;
              margin-bottom: 12px;
              padding-right: 25px;
              position: relative;
            }
            .instructions-list li:before {
              content: "✓";
              color: #02A96C;
              font-weight: bold;
              position: absolute;
              right: 0;
            }
            .notes-box {
              background-color: #fff3e0;
              border-radius: 12px;
              padding: 25px;
              margin: 30px 0;
              border-right: 5px solid #ff9800;
            }
            .notes-title {
              color: #e65100;
              font-size: 20px;
              font-weight: 700;
              margin-bottom: 15px;
            }
            .notes-list {
              list-style-type: none;
              padding-right: 0;
            }
            .notes-list li {
              color: #333;
              font-size: 17px;
              margin-bottom: 12px;
              padding-right: 25px;
              position: relative;
            }
            .notes-list li:before {
              content: "!";
              color: #ff9800;
              font-weight: bold;
              position: absolute;
              right: 0;
            }
            .footer {
              text-align: center;
              margin-top: 40px;
              padding-top: 25px;
              border-top: 2px solid #eee;
            }
            .footer p {
              color: #666;
              font-size: 16px;
              margin-bottom: 10px;
            }
            .signature {
              font-size: 18px;
              font-weight: 700;
              color: #02A96C;
              margin-top: 15px;
            }
            .auto-note {
              color: #999;
              font-size: 14px;
              margin-top: 20px;
              font-style: italic;
            }
            .copyright {
              background-color: #333;
              color: white;
              text-align: center;
              padding: 20px;
              font-size: 14px;
              margin-top: 30px;
            }
            .highlight {
              color: #02A96C;
              font-weight: 700;
            }
            .urgent {
              color: #d32f2f;
              font-weight: 700;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <!-- Header -->
            <div class="header">
              <h1>ایگری ویژن</h1>
              <p>کسانوں کی بہتری کے لیے وقف</p>
            </div>
            
            <!-- Main Content -->
            <div class="content">
              <!-- Title -->
              <h2 class="title">تصدیقی کوڈ</h2>
              
              <!-- Welcome Message -->
              <div class="message">
                <p>عزت مآب کسان بھائی،</p>
                <p>ایگری ویژن ایپ میں داخل ہونے کے لیے آپ کا تصدیقی نمبر مندرجہ ذیل ہے۔</p>
              </div>
              
              <!-- BIG OTP Display -->
              <div class="otp-box">
                <p class="otp-label">آپ کا تصدیقی نمبر:</p>
                
                <!-- BIG OTP Numbers -->
                <div class="otp-code">${otp}</div>
                
                <p class="otp-instruction">براہ کرم یہ نمبر اپنی ایگری ویژن ایپ میں درج کریں</p>
              </div>
              
              <!-- Instructions -->
              <div class="instructions-box">
                <h3 class="instructions-title">ان کاموں پر عمل کریں:</h3>
                <ul class="instructions-list">
                  <li>اپنی <span class="highlight">ایگری ویژن</span> ایپ کھولیں</li>
                  <li><span class="highlight">تصدیقی نمبر</span> والی سکرین پر جائیں</li>
                  <li>اوپر دیا گیا <span class="highlight">${otp}</span> نمبر درج کریں</li>
                  <li><span class="highlight">"تصدیق کریں"</span> والے بٹن پر کلک کریں</li>
                </ul>
              </div>
              
              <!-- Important Notes -->
              <div class="notes-box">
                <h3 class="notes-title">ضروری معلومات:</h3>
                <ul class="notes-list">
                  <li>یہ نمبر صرف <span class="urgent">دس منٹ</span> تک درست رہے گا</li>
                  <li><span class="urgent">کسی کے ساتھ یہ نمبر نہ بانٹیں</span></li>
                  <li>اگر آپ نے تصدیقی نمبر نہیں مانگا، تو اس ای میل کو نظر انداز کریں</li>
                  <li>یہ نمبر صرف آپ کے لیے ہے</li>
                  <li>اس نمبر کو کسی کو نہ بتائیں</li>
                </ul>
              </div>
              
              <!-- Footer Message -->
              <div class="footer">
                <p>شکریہ کہ آپ ایگری ویژن کا حصہ بنے،</p>
                <p class="signature">ایگری ویژن کی ٹیم</p>
                <p class="auto-note">یہ ایک خودکار پیغام ہے، براہ کرم جواب نہ دیں</p>
              </div>
            </div>
            
            <!-- Footer -->
            <div class="copyright">
              <p>© 2024 ایگری ویژن | تمام حقوق محفوظ ہیں</p>
              <p style="color: #aaa; margin-top: 5px;">کسانوں کی بہتری کے لیے وقف</p>
            </div>
          </div>
        </body>
        </html>
      `,
      text: `
ایگری ویژن - تصدیقی نمبر

عزت مآب کسان بھائی،

ایگری ویژن ایپ میں داخل ہونے کے لیے آپ کا تصدیقی نمبر ہے:

${otp}

براہ کرم یہ نمبر اپنی ایگری ویژن ایپ میں درج کریں

ان کاموں پر عمل کریں:
1. اپنی ایگری ویژن ایپ کھولیں
2. تصدیقی نمبر والی سکرین پر جائیں
3. اوپر دیا گیا ${otp} نمبر درج کریں
4. "تصدیق کریں" والے بٹن پر کلک کریں

ضروری معلومات:
• یہ نمبر صرف دس منٹ تک درست رہے گا
• کسی کے ساتھ یہ نمبر نہ بانٹیں
• اگر آپ نے تصدیقی نمبر نہیں مانگا، تو اس ای میل کو نظر انداز کریں
• یہ نمبر صرف آپ کے لیے ہے
• اس نمبر کو کسی کو نہ بتائیں

شکریہ کہ آپ ایگری ویژن کا حصہ بنے،
ایگری ویژن کی ٹیم

© 2024 ایگری ویژن | تمام حقوق محفوظ ہیں
کسانوں کی بہتری کے لیے وقف

یہ ایک خودکار پیغام ہے، براہ کرم جواب نہ دیں
      `
    };

    await transporter.sendMail(mailOptions);
    console.log(`✅ تصدیقی نمبر بھیجا گیا ${email} - نمبر: ${otp}`);
    return true;
    
  } catch (error) {
    console.error('❌ ای میل بھیجنے میں مسئلہ:', error.message);
    return false;
  }
};

module.exports = {
  generateOTP,
  sendEmailOTP
};