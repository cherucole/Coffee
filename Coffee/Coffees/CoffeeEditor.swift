/// Copyright (c) 2022 Kodeco Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import CoffeeKit
import SwiftUI

struct CoffeeEditor: View {
  @ObservedObject var model: CoffeeViewModel
  var coffee: Binding<Coffee>
  @Environment(\.dismiss) var dismiss

  init(model: CoffeeViewModel, coffeeToEdit: Binding<Coffee>) {
    self.model = model
    self.coffee = coffeeToEdit
  }

  var body: some View {
    Form {
      editorContent
    }
    .formStyle(.grouped)
    .navigationTitle(coffee.name)
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          Text("Cancel")
        }
      }
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button {
          Task {
            do {
              try await model.saveCoffee(coffee.wrappedValue)
              dismiss()
            } catch {
              // CoffeeViewModel handles the error alert variables.
            }
          }
        } label: {
          Text("Save")
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.saveCoffeeButton)
      }
    }
    .alert(
      isPresented: $model.showCoffeeErrorAlert,
      error: model.saveCoffeeError
    ) {
      Button("OK", role: .cancel) {
        model.saveCoffeeError = nil
      }
      .accessibilityIdentifier(AccessibilityIdentifiers.closeErrorAlertButton)
    }
  }

  @ViewBuilder
  var editorContent: some View {
    Section {
      Image(systemName: "cup.and.saucer.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(Color.accentColor)
    }

    Section("Coffee Name") {
      TextField(
        "Name",
        text: coffee.name,
        prompt: Text(String(localized: "New Coffee", comment: "New coffee placeholder name."))
      )
    }

    Section("Tasting notes") {
      TextEditor(text: coffee.tastingNotes)
    }

    Section("Flavor Profile") {
      Grid {
        GridRow {
          FlavorView(title: "Sweetness", value: coffee.sweetness)
        }
        GridRow {
          FlavorView(title: "Acidity", value: coffee.acidity)
        }
      }
    }
  }
}

struct FlavorView: View {
  var title: String
  @Binding var value: Int

  var body: some View {
    Text(title)
      .gridCellAnchor(.leading)
      .foregroundStyle(.primary)

    Gauge(
      value: Double(value),
      in: 0...10
    ) {
      EmptyView()
    }
    .tint(Color.secondary)
    .labelsHidden()

    Stepper("\(value)", value: $value)

    Text(value.formatted())
      .gridCellAnchor(.trailing)
      .foregroundStyle(.secondary)
  }
}

struct CoffeeEditor_Previews: PreviewProvider {
  struct Preview: View {
    @State private var coffee = CoffeeViewModel.newCoffee
    @StateObject private var model = CoffeeViewModel.preview

    var body: some View {
      CoffeeEditor(model: model, coffeeToEdit: $coffee)
    }
  }

  static var previews: some View {
    NavigationStack {
      Preview()
    }
  }
}
