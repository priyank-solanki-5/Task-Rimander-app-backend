import User from "../models/User.js";

class UserDao {
  async createUser(userData) {
    return await User.create(userData);
  }

  async findUserByEmail(email) {
    return await User.findOne({ where: { email } });
  }

  async findUserByEmailAndPassword(email, password) {
    return await User.findOne({ where: { email, password } });
  }

  async findUserByEmailAndMobile(email, mobilenumber) {
    return await User.findOne({ where: { email, mobilenumber } });
  }

  async updateUser(user) {
    return await user.save();
  }
}

export default new UserDao();
