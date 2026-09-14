import SwiftUI

struct SubEmotion: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let words: [String]
}

struct CoreEmotion: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let hex: String
    let reflect: String
    let subs: [SubEmotion]

    var color: Color { Color(hex: hex) }
}

/// Ported 1:1 from the `WHEEL` data in the original Framer web app.
enum EmotionWheelData {
    static let core: [CoreEmotion] = [
        CoreEmotion(
            name: "liebend", hex: "#F3D14E",
            reflect: "Verbundenheit und Zuneigung – schön, dass du das gerade spürst.",
            subs: [
                SubEmotion(name: "friedlich", words: ["ruhig", "befriedigt"]),
                SubEmotion(name: "liebevoll", words: ["warmherzig", "mitfühlend"]),
                SubEmotion(name: "romantisch", words: ["leidenschaftlich", "verliebt"]),
                SubEmotion(name: "dankbar", words: ["anerkennend", "verbunden"]),
                SubEmotion(name: "sentimental", words: ["nostalgisch", "zärtlich"]),
                SubEmotion(name: "verzaubert", words: ["fasziniert", "begeistert"]),
            ]),
        CoreEmotion(
            name: "überrascht", hex: "#EFA85C",
            reflect: "Etwas hat dich überrascht – nimm dir einen Moment, es einzuordnen.",
            subs: [
                SubEmotion(name: "überwältigt", words: ["sprachlos", "verblüfft"]),
                SubEmotion(name: "bewegt", words: ["berührt", "angeregt"]),
                SubEmotion(name: "erschrocken", words: ["schockiert", "enttäuscht"]),
                SubEmotion(name: "aufgeregt", words: ["eifrig", "energiegeladen"]),
                SubEmotion(name: "erstaunt", words: ["scheu", "erstaunt"]),
                SubEmotion(name: "verwirrt", words: ["verblüfft", "ernüchtert"]),
            ]),
        CoreEmotion(
            name: "zornig", hex: "#E87E7E",
            reflect: "Zorn zeigt oft, dass eine Grenze überschritten wurde. Was steckt dahinter?",
            subs: [
                SubEmotion(name: "wütend", words: ["nachtragend", "neidisch"]),
                SubEmotion(name: "eifersüchtig", words: ["wütend", "eifersüchtig"]),
                SubEmotion(name: "angeekelt", words: ["verächtlich", "auflehnend"]),
                SubEmotion(name: "kritisch", words: ["skeptisch", "abweisend"]),
                SubEmotion(name: "reizbar", words: ["verärgert", "genervt"]),
                SubEmotion(name: "hasserfüllt", words: ["verletzt", "verärgert"]),
            ]),
        CoreEmotion(
            name: "furchtsam", hex: "#B49BD8",
            reflect: "Angst weist oft auf etwas hin, das dir wichtig ist oder dich schützen will.",
            subs: [
                SubEmotion(name: "erschrocken", words: ["verängstigt", "hilflos"]),
                SubEmotion(name: "unsicher", words: ["unterlegen", "unzulänglich"]),
                SubEmotion(name: "nervös", words: ["besorgt", "ängstlich"]),
                SubEmotion(name: "entsetzt", words: ["beschämt", "furchtbar"]),
                SubEmotion(name: "abgelehnt", words: ["ausgeschlossen", "verfolgt"]),
                SubEmotion(name: "verängstigt", words: ["panisch", "aufgelöst"]),
            ]),
        CoreEmotion(
            name: "traurig", hex: "#80C9A6",
            reflect: "Auch Traurigkeit darf da sein. Sei freundlich zu dir.",
            subs: [
                SubEmotion(name: "einsam", words: ["isoliert", "vernachlässigt"]),
                SubEmotion(name: "verletzt", words: ["gequält", "verwirrt"]),
                SubEmotion(name: "deprimiert", words: ["leer", "elend"]),
                SubEmotion(name: "gelangweilt", words: ["apathisch", "gleichgültig"]),
                SubEmotion(name: "schuldbewusst", words: ["reumütig", "beschämt"]),
                SubEmotion(name: "verzweifelt", words: ["machtlos", "verletzlich"]),
            ]),
        CoreEmotion(
            name: "freudig", hex: "#C2CF74",
            reflect: "Freude tut gut – lass sie ruhig einen Moment nachklingen.",
            subs: [
                SubEmotion(name: "optimistisch", words: ["hoffnungsvoll", "eifrig"]),
                SubEmotion(name: "glücklich", words: ["vergnügt", "begeistert"]),
                SubEmotion(name: "stolz", words: ["triumphierend", "erhaben"]),
                SubEmotion(name: "gut gelaunt", words: ["spielerisch", "gemütlich"]),
                SubEmotion(name: "erfreut", words: ["zufrieden", "befriedigt"]),
                SubEmotion(name: "euphorisch", words: ["jubilieren", "begeistert"]),
            ]),
    ]
}
