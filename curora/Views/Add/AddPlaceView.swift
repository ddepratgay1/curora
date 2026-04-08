// AddPlaceView.swift — Curora
// Add a new place via manual entry OR paste a link.

import SwiftUI
import PhotosUI

struct AddPlaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self)   var auth
    @Environment(PlacesViewModel.self) var placesVM

    // Input mode
    @State private var mode: InputMode = .manual

    // Form fields
    @State private var name:        String = ""
    @State private var city:        String = ""
    @State private var country:     String = ""
    @State private var category:    String = Place.categories[0]
    @State private var vibe:        String = Place.vibes[0]
    @State private var notes:       String = ""
    @State private var pastedLink:  String = ""

    // Image
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    // State
    @State private var isSaving:    Bool = false
    @State private var errorMsg:    String = ""
    @State private var showSuccess: Bool = false

    enum InputMode: String, CaseIterable {
        case manual = "Manual"
        case link   = "Paste Link"
    }

    var canSave: Bool {
        mode == .manual
            ? !name.trimmingCharacters(in: .whitespaces).isEmpty &&
              !city.trimmingCharacters(in: .whitespaces).isEmpty
            : !pastedLink.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cCream.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: CSpacing.lg) {

                        // Mode toggle
                        HStack(spacing: 0) {
                            ForEach(InputMode.allCases, id: \.self) { m in
                                Button(action: {
                                    Haptics.light()
                                    withAnimation(.spring(response: 0.35)) { mode = m }
                                }) {
                                    Text(m.rawValue)
                                        .font(CuroraFont.sansMedium(12))
                                        .foregroundColor(mode == m ? .white : Color.cMuted)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(mode == m ? Color.cDeep : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: CRadius.sm, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(4)
                        .background(Color.cStone.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))

                        if mode == .manual {
                            manualForm
                        } else {
                            linkForm
                        }

                        if !errorMsg.isEmpty {
                            Text(errorMsg)
                                .font(CuroraFont.sans(12))
                                .foregroundColor(Color.cTerracotta)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        // Save button
                        CuroraButton(
                            title:     showSuccess ? "Saved ✓" : "Save Place",
                            style:     showSuccess ? .ghost : .terracotta,
                            isLoading: isSaving
                        ) {
                            Task { await save() }
                        }
                        .disabled(!canSave || isSaving)
                        .opacity(canSave ? 1 : 0.5)

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, CSpacing.side)
                    .padding(.top, CSpacing.md)
                }
            }
            .navigationTitle("Save a Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(CuroraFont.sans(14))
                        .foregroundColor(Color.cMuted)
                }
            }
        }
    }

    // MARK: - Manual form
    private var manualForm: some View {
        VStack(alignment: .leading, spacing: CSpacing.md) {

            // Image picker
            VStack(alignment: .leading, spacing: CSpacing.sm) {
                fieldLabel("Photo (optional)")
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    ZStack {
                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
                        } else {
                            RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                                .fill(Color.cStone.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .overlay(
                                    VStack(spacing: 6) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 22, weight: .ultraLight))
                                            .foregroundColor(Color.cMuted)
                                        Text("Add photo")
                                            .font(CuroraFont.sansLight(11))
                                            .foregroundColor(Color.cMuted)
                                    }
                                )
                        }
                    }
                }
                .onChange(of: selectedItem) { _, item in
                    Task {
                        if let data = try? await item?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }
            }

            curoraField(label: "Place Name *", placeholder: "e.g. Via Carota", text: $name)
            curoraField(label: "City *",       placeholder: "e.g. New York",    text: $city)
            curoraField(label: "Country",      placeholder: "e.g. USA",          text: $country)

            // Category picker
            VStack(alignment: .leading, spacing: CSpacing.sm) {
                fieldLabel("Category")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Place.categories, id: \.self) { cat in
                            Button(action: {
                                Haptics.light()
                                category = cat
                            }) {
                                Text(cat)
                                    .font(CuroraFont.sans(12))
                                    .foregroundColor(category == cat ? .white : Color.cDeep)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(category == cat ? Color.cDeep : Color.cWarmWhite)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(category == cat ? Color.clear : Color.cStone, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            // Vibe picker
            VStack(alignment: .leading, spacing: CSpacing.sm) {
                fieldLabel("Vibe")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Place.vibes, id: \.self) { v in
                            Button(action: {
                                Haptics.light()
                                vibe = v
                            }) {
                                Text(v)
                                    .font(CuroraFont.sans(12))
                                    .foregroundColor(vibe == v ? .white : Color.cDeep)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(vibe == v ? Color.cTerracotta : Color.cWarmWhite)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(vibe == v ? Color.clear : Color.cStone, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            // Notes
            VStack(alignment: .leading, spacing: CSpacing.sm) {
                fieldLabel("Your Note")
                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Why did you save this? What's the vibe?")
                            .font(CuroraFont.sansLight(13))
                            .foregroundColor(Color.cMuted.opacity(0.6))
                            .padding(14)
                    }
                    TextEditor(text: $notes)
                        .font(CuroraFont.sansLight(14))
                        .foregroundColor(Color.cDeep)
                        .frame(minHeight: 90)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                }
                .background(Color.cWarmWhite)
                .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                        .stroke(Color.cStone, lineWidth: 0.5)
                )
            }
        }
    }

    // MARK: - Link form
    private var linkForm: some View {
        VStack(alignment: .leading, spacing: CSpacing.md) {

            VStack(alignment: .leading, spacing: CSpacing.sm) {
                fieldLabel("Paste a link")
                Text("Paste an Instagram, TikTok, or Google Maps URL. Curora will extract the place name automatically.")
                    .font(CuroraFont.sansLight(12))
                    .foregroundColor(Color.cMuted)
                    .lineSpacing(4)
            }

            ZStack(alignment: .topLeading) {
                if pastedLink.isEmpty {
                    Text("https://www.instagram.com/…")
                        .font(CuroraFont.sansLight(13))
                        .foregroundColor(Color.cMuted.opacity(0.5))
                        .padding(14)
                }
                TextEditor(text: $pastedLink)
                    .font(CuroraFont.sans(13))
                    .foregroundColor(Color.cDeep)
                    .frame(minHeight: 70)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .background(Color.cWarmWhite)
            .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                    .stroke(Color.cStone, lineWidth: 0.5)
            )

            // After pasting, still need city
            curoraField(label: "City *", placeholder: "e.g. New York", text: $city)
            curoraField(label: "Category", placeholder: "Restaurant, Café…", text: $category)

            VStack(alignment: .leading, spacing: CSpacing.sm) {
                fieldLabel("Your Note")
                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Any context for yourself?")
                            .font(CuroraFont.sansLight(13))
                            .foregroundColor(Color.cMuted.opacity(0.6))
                            .padding(14)
                    }
                    TextEditor(text: $notes)
                        .font(CuroraFont.sansLight(14))
                        .foregroundColor(Color.cDeep)
                        .frame(minHeight: 70)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                }
                .background(Color.cWarmWhite)
                .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                        .stroke(Color.cStone, lineWidth: 0.5)
                )
            }
        }
    }

    // MARK: - Helpers
    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(CuroraFont.sansMedium(9))
            .kerning(1.5)
            .foregroundColor(Color.cMuted)
    }

    @ViewBuilder
    private func curoraField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: CSpacing.sm) {
            fieldLabel(label)
            TextField(placeholder, text: text)
                .font(CuroraFont.sans(14))
                .foregroundColor(Color.cDeep)
                .padding(14)
                .background(Color.cWarmWhite)
                .clipShape(RoundedRectangle(cornerRadius: CRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CRadius.md, style: .continuous)
                        .stroke(Color.cStone, lineWidth: 0.5)
                )
        }
    }

    // MARK: - Save
    private func save() async {
        guard let userId = auth.user?.id else { return }
        isSaving = true
        errorMsg = ""

        let finalName: String
        let finalURL:  String

        if mode == .link {
            finalURL  = pastedLink.trimmingCharacters(in: .whitespaces)
            // Extract a display name from URL (best-effort)
            finalName = extractName(from: finalURL)
        } else {
            finalURL  = ""
            finalName = name.trimmingCharacters(in: .whitespaces)
        }

        let newPlace = Place(
            id:         UUID().uuidString,
            name:       finalName,
            city:       city.trimmingCharacters(in: .whitespaces),
            country:    country.trimmingCharacters(in: .whitespaces),
            category:   category,
            vibe:       vibe,
            sourceURL:  finalURL,
            imageURL:   "",
            notes:      notes.trimmingCharacters(in: .whitespaces),
            visited:    false,
            savedAt:    Date(),
            userId:     userId
        )

        await placesVM.addPlace(newPlace, image: selectedImage, userId: userId)

        if placesVM.errorMsg.isEmpty {
            showSuccess = true
            Haptics.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { dismiss() }
        } else {
            errorMsg = placesVM.errorMsg
        }
        isSaving = false
    }

    /// Extracts a readable place name from a URL (best-effort).
    private func extractName(from url: String) -> String {
        guard let urlObj = URL(string: url) else { return "Saved Place" }
        // Try to get the last meaningful path component
        let path  = urlObj.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        let raw   = path.last ?? urlObj.host ?? "Saved Place"
        // Clean up: replace hyphens/underscores, title-case
        let clean = raw
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
        return clean.capitalized.isEmpty ? "Saved Place" : clean.capitalized
    }
}
