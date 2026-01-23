import Member from "../models/Member.js";

class MemberDao {
  /**
   * Create a new member
   */
  async createMember(memberData) {
    const member = new Member(memberData);
    return await member.save();
  }

  /**
   * Find member by ID
   */
  async findMemberById(memberId) {
    return await Member.findById(memberId)
      .populate("userId", "username email mobilenumber")
      .populate("documents");
  }

  /**
   * Find all members for a user
   */
  async findMembersByUserId(userId) {
    return await Member.find({ userId })
      .populate("documents")
      .sort({ createdAt: -1 })
      .lean();
  }

  /**
   * Find member by email
   */
  async findMemberByEmail(memberEmail) {
    return await Member.findOne({ memberEmail });
  }

  /**
   * Update member
   */
  async updateMember(memberId, updateData) {
    return await Member.findByIdAndUpdate(memberId, updateData, {
      new: true,
      runValidators: true,
    }).populate("documents");
  }

  /**
   * Delete member
   */
  async deleteMember(memberId) {
    return await Member.findByIdAndDelete(memberId);
  }

  /**
   * Find active members for a user
   */
  async findActiveMembersByUserId(userId) {
    return await Member.find({ userId, isActive: true })
      .sort({ memberName: 1 })
      .lean();
  }

  /**
   * Find emergency contacts for a user
   */
  async findEmergencyContacts(userId) {
    return await Member.find({ userId, emergencyContact: true })
      .sort({ memberName: 1 })
      .lean();
  }

  /**
   * Add document to member
   */
  async addDocumentToMember(memberId, documentId) {
    return await Member.findByIdAndUpdate(
      memberId,
      { $addToSet: { documents: documentId } },
      { new: true },
    ).populate("documents");
  }

  /**
   * Remove document from member
   */
  async removeDocumentFromMember(memberId, documentId) {
    return await Member.findByIdAndUpdate(
      memberId,
      { $pull: { documents: documentId } },
      { new: true },
    ).populate("documents");
  }

  /**
   * Get member count for a user
   */
  async getMemberCount(userId) {
    return await Member.countDocuments({ userId });
  }

  /**
   * Search members by name
   */
  async searchMembersByName(userId, searchQuery) {
    return await Member.find({
      userId,
      memberName: { $regex: searchQuery, $options: "i" },
    })
      .sort({ memberName: 1 })
      .lean();
  }
}

export default new MemberDao();
