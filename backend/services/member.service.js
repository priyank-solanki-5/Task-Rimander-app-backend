import memberDao from "../dao/memberDao.js";
import documentDao from "../dao/documentDao.js";

class MemberService {
  /**
   * Add new member
   */
  async addMember(userId, memberData) {
    // Validate required fields
    if (!memberData.memberName) {
      throw new Error("Member name is required");
    }

    // Check if member already exists with same email (if provided)
    if (memberData.memberEmail) {
      const existingMember = await memberDao.findMemberByEmail(
        memberData.memberEmail,
      );
      if (existingMember && existingMember.userId.toString() === userId) {
        throw new Error("Member with this email already exists");
      }
    }

    // Create member
    const member = await memberDao.createMember({
      userId,
      ...memberData,
      isActive: true,
    });

    return member;
  }

  /**
   * Get member details
   */
  async getMemberDetails(memberId, userId) {
    const member = await memberDao.findMemberById(memberId);

    if (!member) {
      throw new Error("Member not found");
    }

    // Verify ownership
    if (member.userId._id.toString() !== userId) {
      throw new Error("Unauthorized access to this member");
    }

    return member;
  }

  /**
   * Get all members for a user
   */
  async getUserMembers(userId) {
    const members = await memberDao.findMembersByUserId(userId);

    return {
      success: true,
      count: members.length,
      data: members,
    };
  }

  /**
   * Update member information
   */
  async updateMember(memberId, userId, updateData) {
    const member = await memberDao.findMemberById(memberId);

    if (!member) {
      throw new Error("Member not found");
    }

    // Verify ownership
    if (member.userId._id.toString() !== userId) {
      throw new Error("Unauthorized access to this member");
    }

    // Don't allow updating userId
    delete updateData.userId;

    const updatedMember = await memberDao.updateMember(memberId, updateData);

    return updatedMember;
  }

  /**
   * Delete member
   */
  async deleteMember(memberId, userId) {
    const member = await memberDao.findMemberById(memberId);

    if (!member) {
      throw new Error("Member not found");
    }

    // Verify ownership
    if (member.userId._id.toString() !== userId) {
      throw new Error("Unauthorized access to this member");
    }

    // Delete associated documents
    if (member.documents && member.documents.length > 0) {
      await documentDao.deleteDocumentsByIds(member.documents);
    }

    await memberDao.deleteMember(memberId);

    return { success: true, message: "Member deleted successfully" };
  }

  /**
   * Add document to member
   */
  async addDocumentToMember(memberId, userId, documentId) {
    const member = await memberDao.findMemberById(memberId);

    if (!member) {
      throw new Error("Member not found");
    }

    // Verify ownership
    if (member.userId._id.toString() !== userId) {
      throw new Error("Unauthorized access to this member");
    }

    const updatedMember = await memberDao.addDocumentToMember(
      memberId,
      documentId,
    );

    return updatedMember;
  }

  /**
   * Get member's documents
   */
  async getMemberDocuments(memberId, userId) {
    const member = await memberDao.findMemberById(memberId);

    if (!member) {
      throw new Error("Member not found");
    }

    // Verify ownership
    if (member.userId._id.toString() !== userId) {
      throw new Error("Unauthorized access to this member");
    }

    return {
      success: true,
      memberId: memberId,
      memberName: member.memberName,
      documents: member.documents,
      documentCount: member.documents ? member.documents.length : 0,
    };
  }

  /**
   * Get emergency contacts
   */
  async getEmergencyContacts(userId) {
    const contacts = await memberDao.findEmergencyContacts(userId);

    return {
      success: true,
      count: contacts.length,
      data: contacts,
    };
  }

  /**
   * Search members
   */
  async searchMembers(userId, searchQuery) {
    if (!searchQuery || searchQuery.trim().length === 0) {
      throw new Error("Search query is required");
    }

    const results = await memberDao.searchMembersByName(userId, searchQuery);

    return {
      success: true,
      query: searchQuery,
      count: results.length,
      data: results,
    };
  }

  /**
   * Get member statistics for dashboard
   */
  async getMemberStatistics(userId) {
    const totalMembers = await memberDao.getMemberCount(userId);
    const activeMembers = await memberDao.findActiveMembersByUserId(userId);
    const emergencyContacts = await memberDao.findEmergencyContacts(userId);

    return {
      success: true,
      statistics: {
        totalMembers,
        activeMembers: activeMembers.length,
        emergencyContacts: emergencyContacts.length,
        inactiveMembers: totalMembers - activeMembers.length,
      },
    };
  }

  /**
   * Upload document for a member
   */
  async uploadMemberDocument(userId, memberId, documentData) {
    // Verify member exists and belongs to user
    const member = await memberDao.findMemberById(memberId);

    if (!member) {
      throw new Error("Member not found");
    }

    if (member.userId._id.toString() !== userId) {
      throw new Error("Unauthorized access to this member");
    }

    // Create document with member reference (no task required)
    const document = await documentDao.createDocument({
      userId,
      memberId,
      filename: documentData.filename,
      originalName: documentData.originalName,
      mimeType: documentData.mimeType,
      fileSize: documentData.fileSize,
      filePath: documentData.filePath,
    });

    // Add document to member's documents array
    await memberDao.addDocumentToMember(memberId, document._id);

    return document;
  }
}

export default new MemberService();
