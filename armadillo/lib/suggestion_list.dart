// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sysui_widgets/raw_keyboard_input.dart';

import 'suggestion_manager.dart';
import 'suggestion_widget.dart';

const String _kMicImageGrey600 =
    'packages/armadillo/res/ic_mic_grey600_1x_web_24dp.png';

typedef void OnSuggestionSelected(Suggestion suggestion, Rect globalBounds);
typedef void OnAskTextChanged(String text);

class SuggestionList extends StatefulWidget {
  final Key scrollableKey;
  final VoidCallback onAskingStarted;
  final VoidCallback onAskingEnded;
  final OnSuggestionSelected onSuggestionSelected;
  final OnAskTextChanged onAskTextChanged;
  final bool multiColumn;

  SuggestionList({
    Key key,
    this.scrollableKey,
    this.onAskingStarted,
    this.onAskingEnded,
    this.onSuggestionSelected,
    this.onAskTextChanged,
    this.multiColumn,
  })
      : super(key: key);

  @override
  SuggestionListState createState() => new SuggestionListState();
}

class SuggestionListState extends State<SuggestionList> {
  final GlobalKey<RawKeyboardInputState> _inputKey =
      new GlobalKey<RawKeyboardInputState>();
  bool _asking = false;
  Suggestion _selectedSuggestion;

  String get text => _inputKey.currentState?.text;
  void append(String text) {
    _inputKey.currentState?.append(text);
    config.onAskTextChanged?.call(text);
    InheritedSuggestionManager.of(context).askText = this.text;
  }

  void backspace() {
    _inputKey.currentState?.backspace();
    config.onAskTextChanged?.call(text);
    InheritedSuggestionManager.of(context).askText = text;
  }

  void clear() {
    _inputKey.currentState?.clear();
    config.onAskTextChanged?.call(text);
    InheritedSuggestionManager.of(context).askText = null;
  }

  void resetSelection() {
    setState(() {
      _selectedSuggestion = null;
    });
  }

  void onSuggestion(String suggestion) {
    if (suggestion == null || suggestion.isEmpty) {
      return;
    }
    final stringList = text.split(' ');
    if (stringList.isEmpty) {
      return;
    }

    // Remove last word.
    for (int i = 0; i < stringList[stringList.length - 1].length; i++) {
      backspace();
    }

    // Add the suggested word.
    append(suggestion + ' ');
  }

  void stopAsking() {
    setState(() {
      _asking = false;
    });
  }

  void selectFirstSuggestions() {
    List<Suggestion> suggestions =
        InheritedSuggestionManager.of(context).suggestions;
    if (suggestions.isNotEmpty) {
      _onSuggestionSelected(suggestions[0]);
    }
  }

  @override
  Widget build(BuildContext context) => new Stack(
        children: [
          // Ask Anything text field.
          new Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            height: 84.0,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Flexible(
                  flex: 3,
                  child: new GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _asking = !_asking;
                        if (_asking) {
                          if (config.onAskingStarted != null) {
                            config.onAskingStarted();
                          }
                        } else {
                          if (config.onAskingEnded != null) {
                            config.onAskingEnded();
                          }
                        }
                      });
                    },
                    child: new Align(
                      alignment: FractionalOffset.centerLeft,
                      child: new Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: new RawKeyboardInput(
                          key: _inputKey,
                          focused: _asking,
                          onTextChanged: (String text) {
                            InheritedSuggestionManager.of(context).askText =
                                text;
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Microphone.
                new Flexible(
                  flex: 1,
                  child: new GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _asking = !_asking;
                      if (_asking) {
                        if (config.onAskingStarted != null) {
                          config.onAskingStarted();
                        }
                      } else {
                        if (config.onAskingEnded != null) {
                          config.onAskingEnded();
                        }
                      }
                    },
                    child: new Align(
                      alignment: FractionalOffset.centerRight,
                      child: new Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: new Image.asset(
                          _kMicImageGrey600,
                          fit: ImageFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          new Positioned(
            top: 84.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: config.multiColumn
                ? _createTwoColumnBlock(context)
                : _createSingleColumnBlock(context),
          ),
        ],
      );

  Widget _createSingleColumnBlock(BuildContext context) => new Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: new Block(
          scrollableKey: config.scrollableKey,
          children: InheritedSuggestionManager
              .of(context)
              .suggestions
              .map((Suggestion suggestion) => _createSuggestion(suggestion))
              .toList(),
        ),
      );

  Widget _createTwoColumnBlock(BuildContext context) {
    List<Suggestion> suggestions =
        InheritedSuggestionManager.of(context).suggestions;
    int minSuggestionsPerColumn = (suggestions.length / 2).floor();
    int additionalLeftSuggestions = suggestions.length % 2;
    int additionalRightSuggestions =
        (suggestions.length + additionalLeftSuggestions) % 2;
    List<Suggestion> leftSuggestions = new List<Suggestion>.generate(
      minSuggestionsPerColumn + additionalLeftSuggestions,
      (int index) => suggestions[index * 2],
    );
    List<Suggestion> rightSuggestions = new List<Suggestion>.generate(
      minSuggestionsPerColumn + additionalRightSuggestions,
      (int index) => suggestions[index * 2 + 1],
    );
    return new Align(
      alignment: FractionalOffset.topCenter,
      child: new ConstrainedBox(
        constraints: new BoxConstraints(maxWidth: 960.0),
        child: new Block(
          scrollableKey: config.scrollableKey,
          children: new List<Widget>.generate(
            leftSuggestions.length,
            (int index) => new Row(
                  children: [
                    new Flexible(
                        child: _createSuggestion(leftSuggestions[index])),
                    new Container(height: 0.0, width: 16.0),
                    new Flexible(
                      child: index < rightSuggestions.length
                          ? _createSuggestion(rightSuggestions[index])
                          : new Offstage(offstage: true),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  void _onSuggestionSelected(Suggestion suggestion) {
    switch (suggestion.selectionType) {
      case SelectionType.launchStory:
      case SelectionType.modifyStory:
        setState(() {
          _selectedSuggestion = suggestion;
        });
        // We pass the bounds of the suggestion w.r.t.
        // global coordinates so it can be mapped back to
        // local coordinates when it's displayed in the
        // SelectedSuggestionOverlay.
        RenderBox box =
            new GlobalObjectKey(suggestion).currentContext.findRenderObject();
        config.onSuggestionSelected(
          suggestion,
          box.localToGlobal(Point.origin) & box.size,
        );
        break;
      case SelectionType.doNothing:
      default:
        break;
    }
  }

  Widget _createSuggestion(Suggestion suggestion) => new Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6.0,
        ),
        child: new SuggestionWidget(
          key: new GlobalObjectKey(suggestion),
          visible: _selectedSuggestion?.id != suggestion.id,
          suggestion: suggestion,
          onSelected: () => _onSuggestionSelected(suggestion),
        ),
      );
}
