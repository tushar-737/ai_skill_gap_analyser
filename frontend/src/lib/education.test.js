import { describe, expect, it } from "vitest";
import { dedupeEducationPrograms } from "./education";

describe("dedupeEducationPrograms", () => {
    it("keeps one BCA and one B.Com", () => {
        const unique = dedupeEducationPrograms([
            { id: 4, name: "B.C.A." },
            { id: 1, name: "BCA" },
            { id: 7, name: "BCom" },
            { id: 3, name: "B.Com" },
            { id: 9, name: "B.Com Hons" },
            { id: 2, name: "MCA" },
        ]);
        expect(unique.map((item) => item.name)).toEqual(["B.Com", "B.Com Hons", "BCA", "MCA"]);
        expect(unique.find((item) => item.name === "BCA").id).toBe(1);
        expect(unique.find((item) => item.name === "B.Com").id).toBe(3);
    });
});
