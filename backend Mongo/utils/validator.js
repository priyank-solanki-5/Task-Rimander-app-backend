class Validator {
  static isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  static isValidMobileNumber(mobile) {
    const mobileRegex = /^[0-9]{10}$/;
    return mobileRegex.test(mobile);
  }

  static isValidPassword(password) {
    // Minimum 6 characters
    return password && password.length >= 6;
  }

  static validateRegistration(data) {
    const errors = [];

    if (!data.username || data.username.trim() === "") {
      errors.push("Username is required");
    }

    if (!data.email || !this.isValidEmail(data.email)) {
      errors.push("Valid email is required");
    }

    if (!data.mobilenumber || !this.isValidMobileNumber(data.mobilenumber)) {
      errors.push("Valid mobile number is required (10 digits)");
    }

    if (!data.password || !this.isValidPassword(data.password)) {
      errors.push("Password is required (minimum 6 characters)");
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  static validateLogin(data) {
    const errors = [];

    if (!data.email || !this.isValidEmail(data.email)) {
      errors.push("Valid email is required");
    }

    if (!data.password || data.password.trim() === "") {
      errors.push("Password is required");
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  static validatePasswordChange(data) {
    const errors = [];

    if (!data.email || !this.isValidEmail(data.email)) {
      errors.push("Valid email is required");
    }

    if (!data.mobilenumber || !this.isValidMobileNumber(data.mobilenumber)) {
      errors.push("Valid mobile number is required (10 digits)");
    }

    if (!data.newPassword || !this.isValidPassword(data.newPassword)) {
      errors.push("New password is required (minimum 6 characters)");
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }
}

export default Validator;
