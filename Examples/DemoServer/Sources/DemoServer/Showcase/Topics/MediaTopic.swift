import Foundation
import SwiftVaporUI

/// The "Media and embeds" showcase page: video, audio, responsive images,
/// iframes and inline SVG.
enum MediaTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "media",
        title: "Media and embeds",
        tagline: "Video, Audio, Picture, IFrame and inline SVG.",
        intro: [
            "Video and Audio take a single src or a list of Sources, plus fallback content for browsers that cannot play them. Picture lets the browser choose the best image for the screen.",
            "IFrame embeds another page and requires a title for screen readers. SVG draws inline vector graphics, with any shape element written through Element.",
        ],
        examples: [
            Example(
                "audio",
                title: "Audio",
                summary: "The chime is a WAV file the demo server generates. Options are a set: .controls, .autoplay, .loop and .muted."
            ) {
                // snippet: audio
                Audio(options: [.controls], preload: .metadata) {
                    Source(src: "/media/chime.wav", type: "audio/wav")
                    Paragraph("Your browser cannot play audio.")
                }
                // end-snippet
            },

            Example(
                "video",
                title: "Video",
                summary: "Several Sources in different formats, a caption Track and a poster image. The demo ships no video file, so the player shows only its poster."
            ) {
                // snippet: video
                Video(poster: "/images/leaf.svg", options: [.controls, .muted, .playsInline], preload: MediaPreload.none) {
                    Source(src: "/media/market.webm", type: "video/webm")
                    Source(src: "/media/market.mp4", type: "video/mp4")
                    Track(src: "/media/market.vtt", kind: .captions, language: "en", label: "English")
                    Paragraph("Your browser cannot play this video.")
                }
                .frame(width: 240, height: 160)
                // end-snippet
            },

            Example(
                "picture",
                title: "Picture",
                summary: "The browser takes the first Source whose media query and type it supports, and falls back to the Image. Resize the window past 900 pixels to swap leaves."
            ) {
                // snippet: picture
                Picture {
                    Source(srcset: "/images/leaf-wide.svg", media: "(min-width: 900px)", type: "image/svg+xml")
                    Image(src: "/images/leaf.svg", alt: "A green leaf", width: 96, height: 96)
                }
                // end-snippet
            },

            Example(
                "iframe",
                title: "IFrame",
                summary: "Another page, embedded. Frames load lazily, and sandbox locks down untrusted content: an empty sandbox blocks scripts, forms and pop-ups."
            ) {
                // snippet: iframe
                IFrame(src: "/media/embed", title: "Tonight at the market", height: 120, sandbox: "")
                    .style("width: 100%; border: 1px solid #e2e5eb; border-radius: 8px")
                // end-snippet
            },

            Example(
                "svg",
                title: "Inline SVG",
                summary: "SVG sets the viewBox and accessibility; Element writes each shape. With a label the drawing is announced as an image, without one it is decorative."
            ) {
                // snippet: svg
                HStack(spacing: 16) {
                    SVG(viewBox: "0 0 64 96", width: 48, height: 72, label: "A paper lantern") {
                        Element("rect", attributes: ["x": "26", "y": "0", "width": "12", "height": "10", "fill": "#14182b"])
                        Element("ellipse", attributes: ["cx": "32", "cy": "50", "rx": "28", "ry": "38", "fill": "#ff6b4a"])
                        Element("ellipse", attributes: ["cx": "32", "cy": "50", "rx": "14", "ry": "38", "fill": "#ffb347"])
                        Element("rect", attributes: ["x": "24", "y": "86", "width": "16", "height": "10", "fill": "#14182b"])
                    }
                    SVG(viewBox: "0 0 10 10", width: 16, height: 16) {
                        Element("circle", attributes: ["cx": "5", "cy": "5", "r": "5", "fill": "seagreen"])
                    }
                    Span("Open now")
                }
                // end-snippet
            },
        ]
    )

}

/// Registers the routes the media examples load: a generated chime, a
/// wide leaf for the `Picture` example and a small page to embed.
/// - Parameter app: The application to add the routes to.
func registerMediaRoutes(_ app: Application) {
    app.get("media", "chime.wav") { _ in
        Response(status: .ok, headers: ["Content-Type": "audio/wav"], body: .init(data: chimeWAV))
    }
    app.get("images", "leaf-wide.svg") { _ in
        Response(status: .ok, headers: ["Content-Type": "image/svg+xml"], body: .init(string: leafWideSVG))
    }
    app.get("media", "embed") { _ in
        HTMLDocument(title: "Tonight") {
            Paragraph {
                Strong("Tonight: ")
                "lantern walk at "
                Time("21:00", dateTime: "21:00")
                ", live music from 19:00."
            }
            .style("font: 15px system-ui; margin: 12px")
        }
    }
}

/// A one-second, two-note chime as a 16-bit mono WAV file.
let chimeWAV: Data = {
    let sampleRate = 22_050
    let notes: [Double] = [880, 1_318.5]
    var samples: [Int16] = []
    for frequency in notes {
        let count = sampleRate / 2
        for sample in 0..<count {
            let time = Double(sample) / Double(sampleRate)
            let envelope = exp(-time * 6)
            let value = sin(2 * .pi * frequency * time) * envelope * 0.4
            samples.append(Int16(value * Double(Int16.max)))
        }
    }

    /// Appends a little-endian integer to `data`.
    /// - Parameters:
    ///   - data: The data to append to.
    ///   - value: The value to append.
    func append<Value: FixedWidthInteger>(_ data: inout Data, _ value: Value) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }

    var data = Data("RIFF".utf8)
    append(&data, UInt32(36 + samples.count * 2))
    data.append(contentsOf: Array("WAVEfmt ".utf8))
    append(&data, UInt32(16))
    append(&data, UInt16(1))
    append(&data, UInt16(1))
    append(&data, UInt32(sampleRate))
    append(&data, UInt32(sampleRate * 2))
    append(&data, UInt16(2))
    append(&data, UInt16(16))
    data.append(contentsOf: Array("data".utf8))
    append(&data, UInt32(samples.count * 2))
    for sample in samples {
        append(&data, sample)
    }
    return data
}()

/// A wider, darker leaf, which the `Picture` example shows on wide screens.
let leafWideSVG = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96"><path d="M12 84C12 40 40 12 84 12c0 44-28 72-72 72z" fill="#1f6b35"/><path d="M12 84L70 26" stroke="#e3f4e7" stroke-width="3"/></svg>
"""
