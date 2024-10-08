# Proxy Utilities

This article describes the KeyboardKit proxy engine and its utilities.

@Metadata {

    @PageImage(
        purpose: card,
        source: "Page",
        alt: "Page icon"
    )

    @PageColor(blue)
}

iOS keyboards use a `UITextDocumentProxy` to integrate with the currently selected text field. The proxy lets you insert and delete text, get the currently selected text, move the input cursor, etc.

The native APIs are however quite limited, and make it hard to get detailed text information and to perform many standard operations. For instance, you have to write code to get the current word or sentence, understand where the cursor is, etc.

KeyboardKit therefore adds a bunch of extension to the `UITextDocumentProxy` to make things easier. ``KeyboardInputViewController`` also has a custom ``KeyboardInputViewController/textDocumentProxy`` that lets you do even more. 

👑 [KeyboardKit Pro][Pro] unlocks the ability to read the full content of the current document. Information about Pro features can be found at the end of this article.



## Proxy namespace

KeyboardKit has a ``Proxy`` namespace with proxy-related types. It currently only contains utils when it's part of a KeyboardKit Pro build.



## Proxy extensions

KeyboardKit extends the native ``UIKit/UITextDocumentProxy`` with additional capabilities, such as the ability to get more content from the document, analyze words, sentences & quotations, end the current sentence, etc.

Here's a list of extensions that are automatically applied to the text document proxy when you import KeyboardKit:

* ``UIKit/UITextDocumentProxy/currentWord``
* ``UIKit/UITextDocumentProxy/currentWordPreCursorPart``
* ``UIKit/UITextDocumentProxy/currentWordPostCursorPart``
* ``UIKit/UITextDocumentProxy/deleteBackward(range:)``
* ``UIKit/UITextDocumentProxy/deleteBackward(times:)``
* ``UIKit/UITextDocumentProxy/documentContext``
* ``UIKit/UITextDocumentProxy/endSentence(withText:)``
* ``UIKit/UITextDocumentProxy/fullDocumentContext(config:)``
* ``UIKit/UITextDocumentProxy/hasAutocompleteInsertedSpace``
* ``UIKit/UITextDocumentProxy/hasAutocompleteRemovedSpace``
* ``UIKit/UITextDocumentProxy/hasCurrentWord``
* ``UIKit/UITextDocumentProxy/hasUnclosedAlternateQuotationBeforeInput(for:)``
* ``UIKit/UITextDocumentProxy/hasUnclosedQuotationBeforeInput(for:)``
* ``UIKit/UITextDocumentProxy/insertAutocompleteSuggestion(_:tryInsertSpace:)``
* ``UIKit/UITextDocumentProxy/insertDiacritic(_:)``
* ``UIKit/UITextDocumentProxy/isCursorAtNewSentence``
* ``UIKit/UITextDocumentProxy/isCursorAtNewSentenceWithTrailingWhitespace``
* ``UIKit/UITextDocumentProxy/isCursorAtNewWord``
* ``UIKit/UITextDocumentProxy/isCursorAtTheEndOfTheCurrentWord``
* ``UIKit/UITextDocumentProxy/isReadingFullDocumentContext``
* ``UIKit/UITextDocumentProxy/preferredQuotationReplacement(whenInserting:for:)``
* ``UIKit/UITextDocumentProxy/replaceCurrentWord(with:)``
* ``UIKit/UITextDocumentProxy/sentenceBeforeInput``
* ``UIKit/UITextDocumentProxy/sentenceDelimiters``
* ``UIKit/UITextDocumentProxy/tryInsertSpaceAfterAutocomplete()``
* ``UIKit/UITextDocumentProxy/tryRemoveAutocompleteInsertedSpace()``
* ``UIKit/UITextDocumentProxy/tryReinsertAutocompleteRemovedSpace()``
* ``UIKit/UITextDocumentProxy/wordBeforeInput``

See the ``UIKit/UITextDocumentProxy`` documentation for more information and a complete list of extension.



## 👑 KeyboardKit Pro

[KeyboardKit Pro][Pro] unlocks additional ``UIKit/UITextDocumentProxy`` capabilities, like the ability to read the full document content instead of just the content closest to the input cursor.


### How to read the full document context

As you may have noticed, the ``UIKit/UITextDocumentProxy`` ``UIKit/UITextDocumentProxy/documentContext`` functions don't return the full document content before and after the input cursor. Any new line may stop the proxy from looking for more content.

This means that you will most likely only get a partial text result, which makes it hard to build more complex features, like proof-reading a document, use other AI-based features that require more context, etc.

KeyboardKit Pro therefore unlocks additional capabilities to read *all* text from the document, by moving the text cursor in careful ways to unlock more content, then returning the input cursor to the original position.

To read *all* the text from the document, just use the ``UIKit/UITextDocumentProxy/fullDocumentContext(config:)`` functions instead of ``UIKit/UITextDocumentProxy/documentContext``:

```swift
struct KeyboardView: View {

    @EnvironmentObject
    private var context: KeyboardContext

    var body: some View {
        VStack {
            Button("Get the full document context") {
                Task {
                    let proxy = context.textDocumentProxy
                    let result = try? await proxy.fullDocumentContext()
                    await MainActor.run {
                        print(result?.fullDocumentContext)
                        print(result?.fullDocumentContextBeforeInput)
                        print(result?.fullDocumentContextAfterInput)
                    }
                }
            }
        }
    }
}
```

These functions are async, since they will read the document by moving the input cursor in intricate ways. It's not a fail-safe operation, but has been tweaked to provide as accurate results as possible with the current approach.

You can pass in a custom configuration to configure the read operation. It lets you tweak factors like sleep time and how many times to try to read more content at the detected end.

Since the full document context functions are async, you must wrap them in a task when calling them from SwiftUI or non-async places.


[Pro]: https://github.com/KeyboardKit/KeyboardKitPro
