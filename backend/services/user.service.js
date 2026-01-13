import userDao from "../dao/userDao.js";

class UserService {
  async registerUser(username, mobilenumber, email, password) {
    // Check if user already exists
    const existingUser = await userDao.findUserByEmail(email);
    if (existingUser) {
      throw new Error("User with this email already exists");
    }

    // Create new user
    const user = await userDao.createUser({
      username,
      mobilenumber,
      email,
      password,
    });

    return user;
  }

  async loginUser(email, password) {
    const user = await userDao.findUserByEmailAndPassword(email, password);
    if (!user) {
      throw new Error("Invalid credentials");
    }

    return user;
  }

  async changePassword(email, mobilenumber, newPassword) {
    const user = await userDao.findUserByEmailAndMobile(email, mobilenumber);
    if (!user) {
      throw new Error("User not found or email/mobile number does not match");
    }

    user.password = newPassword;
    await userDao.updateUser(user);

    return { message: "Password changed successfully" };
  }
}

export default new UserService();
