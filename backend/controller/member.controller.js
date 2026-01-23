import memberService from "../services/member.service.js";

class MemberController {
  /**
   * Add a new member
   * POST /api/members
   */
  async addMember(req, res) {
    try {
      const userId = req.user.id;
      const memberData = req.body;

      const member = await memberService.addMember(userId, memberData);

      res.status(201).json({
        success: true,
        message: "Member added successfully",
        data: member,
      });
    } catch (error) {
      res.status(400).json({ success: false, error: error.message });
    }
  }

  /**
   * Get all members for the logged-in user
   * GET /api/members
   */
  async getMembers(req, res) {
    try {
      const userId = req.user.id;

      const result = await memberService.getUserMembers(userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }

  /**
   * Get specific member details
   * GET /api/members/:id
   */
  async getMemberDetails(req, res) {
    try {
      const userId = req.user.id;
      const memberId = req.params.id;

      const member = await memberService.getMemberDetails(memberId, userId);

      res.status(200).json({
        success: true,
        data: member,
      });
    } catch (error) {
      res
        .status(error.message.includes("Unauthorized") ? 403 : 404)
        .json({ success: false, error: error.message });
    }
  }

  /**
   * Update member information
   * PUT /api/members/:id
   */
  async updateMember(req, res) {
    try {
      const userId = req.user.id;
      const memberId = req.params.id;
      const updateData = req.body;

      const updatedMember = await memberService.updateMember(
        memberId,
        userId,
        updateData,
      );

      res.status(200).json({
        success: true,
        message: "Member updated successfully",
        data: updatedMember,
      });
    } catch (error) {
      res
        .status(error.message.includes("Unauthorized") ? 403 : 404)
        .json({ success: false, error: error.message });
    }
  }

  /**
   * Delete member
   * DELETE /api/members/:id
   */
  async deleteMember(req, res) {
    try {
      const userId = req.user.id;
      const memberId = req.params.id;

      const result = await memberService.deleteMember(memberId, userId);

      res.status(200).json(result);
    } catch (error) {
      res
        .status(error.message.includes("Unauthorized") ? 403 : 404)
        .json({ success: false, error: error.message });
    }
  }

  /**
   * Get member's documents
   * GET /api/members/:id/documents
   */
  async getMemberDocuments(req, res) {
    try {
      const userId = req.user.id;
      const memberId = req.params.id;

      const result = await memberService.getMemberDocuments(memberId, userId);

      res.status(200).json(result);
    } catch (error) {
      res
        .status(error.message.includes("Unauthorized") ? 403 : 404)
        .json({ success: false, error: error.message });
    }
  }

  /**
   * Get emergency contacts
   * GET /api/members/emergency/contacts
   */
  async getEmergencyContacts(req, res) {
    try {
      const userId = req.user.id;

      const result = await memberService.getEmergencyContacts(userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }

  /**
   * Search members
   * GET /api/members/search?q=searchQuery
   */
  async searchMembers(req, res) {
    try {
      const userId = req.user.id;
      const { q } = req.query;

      const result = await memberService.searchMembers(userId, q);

      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ success: false, error: error.message });
    }
  }

  /**
   * Get member statistics
   * GET /api/members/stats/overview
   */
  async getMemberStatistics(req, res) {
    try {
      const userId = req.user.id;

      const result = await memberService.getMemberStatistics(userId);

      res.status(200).json(result);
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }

  /**
   * Upload document for a member
   * POST /api/members/:id/upload-document
   */
  async uploadMemberDocument(req, res) {
    try {
      const userId = req.user.id;
      const memberId = req.params.id;

      // Validate file upload
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: "No file provided",
        });
      }

      const documentData = {
        filename: req.file.filename,
        originalName: req.file.originalname,
        mimeType: req.file.mimetype,
        fileSize: req.file.size,
        filePath: req.file.path,
      };

      const document = await memberService.uploadMemberDocument(
        userId,
        memberId,
        documentData,
      );

      res.status(201).json({
        success: true,
        message: "Document uploaded successfully for member",
        data: document,
      });
    } catch (error) {
      res
        .status(error.message.includes("Unauthorized") ? 403 : 400)
        .json({ success: false, error: error.message });
    }
  }
}

export default new MemberController();
