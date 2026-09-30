import SwiftUI

/// Gentle follow-up questions per feeling, shown on the result screen.
enum Reflection {
    static func questions(core: String, sub: String) -> [String] {
        bySub["\(core)|\(sub)"] ?? byCore[core] ?? ["Was brauchst du gerade?"]
    }

    private static let byCore: [String: [String]] = [
        "liebend": ["Wem möchtest du das gerade zeigen?", "Was hat dieses Gefühl ausgelöst?"],
        "überrascht": ["Was hast du anders erwartet?", "Was sagt dir diese Überraschung?"],
        "zornig": ["Welche Grenze wurde gerade überschritten?", "Was müsste passieren, damit es leichter wird?"],
        "furchtsam": ["Wovor möchte dich die Angst schützen?", "Was würde dir jetzt Sicherheit geben?"],
        "traurig": ["Was hast du verloren oder vermisst du?", "Was würdest du einer Freundin jetzt sagen?"],
        "freudig": ["Was hat dazu beigetragen?", "Wie kannst du diesen Moment noch etwas halten?"],
    ]

    private static let bySub: [String: [String]] = [
        "liebend|friedlich": ["Was hat dir heute Ruhe geschenkt?", "Wo möchtest du mehr davon in deinem Alltag?"],
        "liebend|liebevoll": ["Wem gilt dieses Gefühl gerade?", "Wie könntest du es heute zeigen?"],
        "liebend|romantisch": ["Was genau berührt dich an diesem Menschen?", "Welchen kleinen Moment möchtest du dir merken?"],
        "liebend|dankbar": ["Wofür genau bist du dankbar?", "Wem könntest du heute Danke sagen?"],
        "liebend|sentimental": ["Welche Erinnerung ist gerade da?", "Was davon möchtest du mitnehmen?"],
        "liebend|verzaubert": ["Was hat dich so fasziniert?", "Wie kannst du dir dieses Staunen bewahren?"],

        "überrascht|überwältigt": ["Was ist gerade zu viel auf einmal?", "Was ist der kleinste nächste Schritt?"],
        "überrascht|bewegt": ["Was hat dich berührt?", "Was sagt das über das, was dir wichtig ist?"],
        "überrascht|erschrocken": ["Was ist gerade passiert?", "Was brauchst du, um wieder anzukommen?"],
        "überrascht|aufgeregt": ["Worauf freust du dich?", "Wohin willst du diese Energie lenken?"],
        "überrascht|erstaunt": ["Was hat dich gerade staunen lassen?", "Was möchtest du darüber noch herausfinden?"],
        "überrascht|verwirrt": ["Was passt gerade nicht zusammen?", "Wen könntest du fragen?"],

        "zornig|wütend": ["Was genau hat dich wütend gemacht?", "Was ist dir dabei wichtig, das verletzt wurde?"],
        "zornig|eifersüchtig": ["Was wünschst du dir eigentlich?", "Was fehlt dir gerade?"],
        "zornig|angeekelt": ["Was stößt dich gerade ab?", "Welcher deiner Werte meldet sich hier?"],
        "zornig|kritisch": ["Was stört dich konkret?", "Was wäre ein fairer nächster Schritt?"],
        "zornig|reizbar": ["Wann hast du heute zuletzt Pause gemacht?", "Was könnte dir gerade Druck nehmen?"],
        "zornig|hasserfüllt": ["Welche Verletzung liegt unter diesem Gefühl?", "Mit wem kannst du darüber sprechen?"],

        "furchtsam|erschrocken": ["Was hat dich erschreckt?", "Bist du gerade in Sicherheit?"],
        "furchtsam|unsicher": ["Woran zweifelst du gerade?", "Was hast du schon einmal geschafft, das ähnlich war?"],
        "furchtsam|nervös": ["Was steht dir bevor?", "Was liegt davon in deiner Hand?"],
        "furchtsam|entsetzt": ["Was ist passiert, das dich so trifft?", "Wer könnte jetzt bei dir sein?"],
        "furchtsam|abgelehnt": ["Wer oder was hat dich ausgeschlossen?", "Wo fühlst du dich trotzdem zugehörig?"],
        "furchtsam|verängstigt": ["Was würde dir jetzt Halt geben?", "Wen könntest du jetzt anrufen?"],

        "traurig|einsam": ["Wem könntest du heute schreiben?", "Wann hast du dich zuletzt verbunden gefühlt?"],
        "traurig|verletzt": ["Was hat dich verletzt?", "Was hättest du dir stattdessen gewünscht?"],
        "traurig|deprimiert": ["Was ist heute eine kleine Sache, die dir guttun könnte?", "Wer weiß, wie es dir gerade geht?"],
        "traurig|gelangweilt": ["Was fehlt dir gerade?", "Was hat dich früher begeistert?"],
        "traurig|schuldbewusst": ["Was bereust du?", "Was kannst du wiedergutmachen – und was darfst du dir verzeihen?"],
        "traurig|verzweifelt": ["Was ist gerade am schwersten?", "Wer kann dich jetzt unterstützen?"],

        "freudig|optimistisch": ["Worauf hoffst du?", "Was kannst du heute dafür tun?"],
        "freudig|glücklich": ["Was macht dich gerade glücklich?", "Mit wem möchtest du das teilen?"],
        "freudig|stolz": ["Worauf bist du stolz?", "Was hast du dafür getan?"],
        "freudig|gut gelaunt": ["Was hat deine Laune gehoben?", "Wie kannst du das heute weitergeben?"],
        "freudig|erfreut": ["Was hat dich gefreut?", "Was davon möchtest du öfter erleben?"],
        "freudig|euphorisch": ["Was ist gerade passiert?", "Wie möchtest du diesen Moment festhalten?"],
    ]
}

/// A one-minute exercise matched to the core feeling.
struct Exercise: Identifiable {
    enum Kind {
        /// Breathing loop: phases of (label, seconds, circle scale 0…1).
        case breathing([(label: String, seconds: Double, scale: CGFloat)])
        /// Guided prompts, each shown for `seconds`.
        case guided(steps: [String], seconds: Double)
    }

    let id: String
    let title: String
    let intro: String
    let kind: Kind
    let colorHex: String

    static let duration: Double = 60

    static func forCore(_ core: CoreEmotion) -> Exercise {
        switch core.name {
        case "zornig":
            return Exercise(
                id: "calm-breath", title: "Ruhig atmen",
                intro: "Langes Ausatmen beruhigt dein Nervensystem. Atme mit dem Kreis.",
                kind: .breathing([("Einatmen", 4, 1), ("Ausatmen", 6, 0.35)]),
                colorHex: core.hex)
        case "furchtsam":
            return Exercise(
                id: "grounding", title: "5-4-3-2-1 Erdung",
                intro: "Hol dich mit deinen Sinnen ins Hier und Jetzt zurück.",
                kind: .guided(steps: [
                    "Nenne 5 Dinge, die du siehst.",
                    "Spüre 4 Dinge, die du berührst.",
                    "Höre 3 Geräusche um dich herum.",
                    "Nimm 2 Gerüche wahr.",
                    "Finde 1 Sache, die du schmeckst – oder atme einmal tief durch.",
                ], seconds: 12),
                colorHex: core.hex)
        case "traurig":
            return Exercise(
                id: "compassion", title: "Mitgefühl mit dir",
                intro: "Leg eine Hand aufs Herz und lies die Sätze langsam mit.",
                kind: .guided(steps: [
                    "Das ist gerade ein schwerer Moment.",
                    "Traurigkeit gehört zum Menschsein. Ich bin damit nicht allein.",
                    "Darf ich freundlich zu mir sein.",
                    "Darf ich mir geben, was ich gerade brauche.",
                    "Atme noch einmal tief ein – und lass langsam los.",
                ], seconds: 12),
                colorHex: core.hex)
        case "überrascht":
            return Exercise(
                id: "box-breath", title: "Box-Atmung",
                intro: "Vier gleich lange Phasen helfen dir, wieder anzukommen.",
                kind: .breathing([("Einatmen", 4, 1), ("Halten", 4, 1), ("Ausatmen", 4, 0.35), ("Halten", 4, 0.35)]),
                colorHex: core.hex)
        default:
            return Exercise(
                id: "savor", title: "Moment genießen",
                intro: "Schöne Gefühle wirken länger, wenn du sie bewusst wahrnimmst.",
                kind: .guided(steps: [
                    "Schließ kurz die Augen und spür das Gefühl.",
                    "Wo in deinem Körper nimmst du es wahr?",
                    "Welches Bild oder welcher Moment gehört dazu?",
                    "Atme es ein, als würdest du es speichern.",
                    "Lächle – und nimm es mit in deinen Tag.",
                ], seconds: 12),
                colorHex: core.hex)
        }
    }
}
