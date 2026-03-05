const crypto = require("crypto");

const ALGO = "aes-256-cbc";
const SECRET_KEY = process.env.PHONE_SECRET_KEY; // must be 32 chars
const IV = Buffer.from(process.env.PHONE_IV, "utf8"); // convert string to Buffer

exports.encrypt = (text) => {
  const cipher = crypto.createCipheriv(ALGO, Buffer.from(SECRET_KEY, "utf8"), IV);
  let encrypted = cipher.update(text, "utf8");
  encrypted = Buffer.concat([encrypted, cipher.final()]);
  return encrypted.toString("hex");
};

exports.decrypt = (data) => {
  try {
    const encryptedText = Buffer.from(data, "hex");
    const decipher = crypto.createDecipheriv(ALGO, Buffer.from(SECRET_KEY, "utf8"), IV);
    let decrypted = decipher.update(encryptedText);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    return decrypted.toString("utf8");
  } catch (err) {
    console.error("Decryption failed:", err.message);
    return data; // fallback if decryption fails
  }
};
