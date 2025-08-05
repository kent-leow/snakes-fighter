import { ValidationHelper } from "../utils/validation";

describe("ValidationHelper", () => {
  describe("validateRoomCode", () => {
    it("should validate correct room codes", () => {
      expect(ValidationHelper.validateRoomCode("ABC123")).toBe(true);
      expect(ValidationHelper.validateRoomCode("XYZ789")).toBe(true);
      expect(ValidationHelper.validateRoomCode("123456")).toBe(true);
    });

    it("should reject invalid room codes", () => {
      expect(ValidationHelper.validateRoomCode("abc123")).toBe(false); // lowercase
      expect(ValidationHelper.validateRoomCode("AB12")).toBe(false); // too short
      expect(ValidationHelper.validateRoomCode("ABC1234")).toBe(false); // too long
      expect(ValidationHelper.validateRoomCode("ABC@12")).toBe(false); // invalid character
    });
  });

  describe("validatePlayerName", () => {
    it("should validate correct player names", () => {
      expect(ValidationHelper.validatePlayerName("Player1")).toBe(true);
      expect(ValidationHelper.validatePlayerName("John Doe")).toBe(true);
      expect(ValidationHelper.validatePlayerName("test_user")).toBe(true);
      expect(ValidationHelper.validatePlayerName("player.123")).toBe(true);
    });

    it("should reject invalid player names", () => {
      expect(ValidationHelper.validatePlayerName("")).toBe(false); // empty
      expect(ValidationHelper.validatePlayerName("a".repeat(21))).toBe(false); // too long
      expect(ValidationHelper.validatePlayerName("test<user>")).toBe(false); // invalid characters
    });
  });

  describe("generateRoomCode", () => {
    it("should generate valid room codes", () => {
      const code1 = ValidationHelper.generateRoomCode();
      const code2 = ValidationHelper.generateRoomCode();

      expect(code1).toHaveLength(6);
      expect(code2).toHaveLength(6);
      expect(code1).not.toBe(code2); // Should be different
      expect(ValidationHelper.validateRoomCode(code1)).toBe(true);
      expect(ValidationHelper.validateRoomCode(code2)).toBe(true);
    });
  });

  describe("sanitizeString", () => {
    it("should sanitize strings correctly", () => {
      expect(ValidationHelper.sanitizeString("  hello  ")).toBe("hello");
      expect(ValidationHelper.sanitizeString("test<script>")).toBe("testscript");
      expect(ValidationHelper.sanitizeString("safe text")).toBe("safe text");
    });
  });
});
