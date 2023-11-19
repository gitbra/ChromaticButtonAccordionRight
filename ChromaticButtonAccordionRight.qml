//=============================================================================
// Chromatic button accordion, right hand - Plugin for MuseScore
// Copyright © 2023 Alexandre Bréard
// Homepage: https://github.com/gitbra/ChromaticButtonAccordionRight
// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//=============================================================================
// https://musescore.org/en/handbook/developers-handbook/plugins-3x
// https://musescore.org/en/developers-handbook/references/musescore-internal-score-representation
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/index.html
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/annotated.html
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/namespace_ms.html#a16b11be27a8e9362dd122c4d879e01ae
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/class_ms_1_1_plugin_a_p_i_1_1_element.html
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/class_ms_1_1_plugin_a_p_i_1_1_plugin_a_p_i.html
// Examples: https://musescore.org/en/node/320673
// Debugger: https://musescore.org/en/node/320499
// MuseScore 4: https://musescore.org/en/node/337468
// https://doc.qt.io/archives/qt-5.9/qmltypes.html
// https://static.roland.com/assets/media/pdf/FR-1x_e02_W.pdf
//=============================================================================

import QtQuick 2.2
import QtQuick.Controls 1.1
import MuseScore 3.0

MuseScore {

    //=============================================================================
    // Meta info

    version: "0.3"
    description: "Musical tool for your chromatic button accordion: layout, fingering, chords and harmonization"
    menuPath: "Plugins.ChromaticButtonAccordionRight"
    requiresScore: true

    id: mainapp
    pluginType: "dialog"                    // Replace by "dock" in MuseScore 3
    dockArea: "right"
    width: 280
    height: 780

    property var rotate: false              // Manual set only
    property var button_width: 30
    property var button_height: 20
    property var button_spacing: 5
    property var buttons: []

    property var c_keys_txt: Array('C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B')
    property var c_flatkeys_txt: Array('C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B')  // "♭" takes more space than "b"
    property var c_black: Array(false, true, false, true, false, false, true, false, true, false, true, false)


    //=============================================================================
    // User interface

    function getButtonPosition(x, y) {
        return {x: (button_width + button_spacing) * x + (2 * button_spacing) + 10,
                y: (button_height + button_spacing) * (y - 1) + (2 * button_spacing) * x + 60};
    }

    onRun: {
        // Check
        if (typeof curScore === 'undefined')
            return;

        // Basic layout
        var x, y, pos, but, pivot;
        pivot = getButtonPosition(2, 9);
        for (y=0; y<19; y++) {
            for (x=0; x<5; x++) {
                but = Qt.createQmlObject('import QtQuick 2.2; Rectangle {width:'+button_width+'; height:'+button_height+'; visible:true; border.color:"black"; Text {anchors.centerIn:parent}}', mainArea);
                pos = getButtonPosition(x, y);
                if (rotate) {
                    pos.x += 2 * (pivot.x - pos.x);
                    pos.y += 2 * (pivot.y - pos.y);
                }
                but.x = pos.x;
                but.y = pos.y;
                buttons.push(Qt.createQmlObject('import QtQuick 2.2; Text {anchors.centerIn:parent}', but));
            }
        }
        refreshAccordion(qLayout.currentIndex);
    }

    Component.onCompleted: {
        if (mscoreMajorVersion >= 4) {
            title = 'Chromatic button accordion'
            // thumbnailName = 'none.png'
            categoryCode = "Notes & Rest"
        }
    }


    //=============================================================================
    // Computation

    function key2us(key) {
        return c_keys_txt[key % 12] + (Math.floor(key / 12) - 1);
    }

    function reduceChordNotation(chord) {
        var prev;
        do {
            prev = chord;
            chord = chord.replace('#', '♯').replace('♭', 'b')
                         .replace('minor', 'm').replace('Minor', 'm').replace('MINOR', 'm')
                         .replace('min', 'm').replace('Min', 'm').replace('MIN', 'm')
                         .replace('major', 'M').replace('Major', 'M').replace('MAJOR', 'M')
                         .replace('maj', 'M').replace('Maj', 'M').replace('MAJ', 'M')
                         //.replace('ma', 'M').replace('Ma', 'M').replace('MA', 'M')
                         .replace('^', 'M') // Δ
                         .replace('Do', 'C').replace('do', 'C')
                         .replace('Re', 'D').replace('re', 'D')
                         .replace('Mi', 'E').replace('mi', 'E')
                         .replace('Fa', 'F').replace('fa', 'F')
                         .replace('Sol', 'G').replace('sol', 'G')
                         .replace('La', 'A').replace('la', 'A')
                         .replace('Si', 'B').replace('si', 'B')
                         .replace('(', '').replace(')', '')
                         .replace('Cb', 'B').replace('B♯', 'C')
                         .replace('E♯', 'F').replace('Fb', 'E')
                         .replace('.', '');
        } while (chord != prev);
        return chord;
    }

    function getScope() {
        return [(curScore.selection.isRange ? curScore.selection.startSegment.tick : curScore.firstMeasure.firstSegment.tick),
                (curScore.selection.isRange && curScore.selection.endSegment ? curScore.selection.endSegment.tick : curScore.lastSegment.tick)];
    }

    function inScope(cursor, scope) {
        return (cursor == null ? false : ((scope[0] <= cursor.tick) && (cursor.tick < scope[1])));
    }

    function refreshAccordion(id) {
        var // Types of accordions
            accordion_c_europe  = Array(null, null, null, 48, 49, null, 49, 50, 51, 52, 51, 52, 53, 54, 55, 54, 55, 56, 57, 58, 57, 58, 59, 60, 61, 60, 61, 62, 63, 64, 63, 64, 65, 66, 67, 66, 67, 68, 69, 70, 69, 70, 71, 72, 73, 72, 73, 74, 75, 76, 75, 76, 77, 78, 79, 78, 79, 80, 81, 82, 81, 82, 83, 84, 85, 84, 85, 86, 87, 88, 87, 88, 89, 90, 91, 90, 91, 92, 93, 94, 93, 94, 95, 96, 97, 96, 97, 98, 99, null, 99, 100, null, null, null),
            accordion_c_griff2  = Array(null, null, null, 51, 53, null, 50, 52, 54, 56, 51, 53, 55, 57, 59, 54, 56, 58, 60, 62, 57, 59, 61, 63, 65, 60, 62, 64, 66, 68, 63, 65, 67, 69, 71, 66, 68, 70, 72, 74, 69, 71, 73, 75, 77, 72, 74, 76, 78, 80, 75, 77, 79, 81, 83, 78, 80, 82, 84, 86, 81, 83, 85, 87, 89, 84, 86, 88, 90, 92, 87, 89, 91, 93, 95, 90, 92, 94, 96, 98, 93, 95, 97, 99, 101, 96, 98, 100, 102, null, 99, 101, null, null, null),
            accordion_b_bajan   = Array(null, null, null, 50, 52, null, 49, 51, 53, 55, 50, 52, 54, 56, 58, 53, 55, 57, 59, 61, 56, 58, 60, 62, 64, 59, 61, 63, 65, 67, 62, 64, 66, 68, 70, 65, 67, 69, 71, 73, 68, 70, 72, 74, 76, 71, 73, 75, 77, 79, 74, 76, 78, 80, 82, 77, 79, 81, 83, 85, 80, 82, 84, 86, 88, 83, 85, 87, 89, 91, 86, 88, 90, 92, 94, 89, 91, 93, 95, 97, 92, 94, 96, 98, 100, 95, 97, 99, 101, null, 98, 100, null, null, null),
            accordion_b_finland = Array(null, null, null, 49, 50, null, 50, 51, 52, 53, 52, 53, 54, 55, 56, 55, 56, 57, 58, 59, 58, 59, 60, 61, 62, 61, 62, 63, 64, 65, 64, 65, 66, 67, 68, 67, 68, 69, 70, 71, 70, 71, 72, 73, 74, 73, 74, 75, 76, 77, 76, 77, 78, 79, 80, 79, 80, 81, 82, 83, 82, 83, 84, 85, 86, 85, 86, 87, 88, 89, 88, 89, 90, 91, 92, 91, 92, 93, 94, 95, 94, 95, 96, 97, 98, 97, 98, 99, 100, null, 100, 101, null, null, null),
            accordion_b_griff1  = Array(null, null, null, null, 48, null, 48, 49, 50, 51, 50, 51, 52, 53, 54, 53, 54, 55, 56, 57, 56, 57, 58, 59, 60, 59, 60, 61, 62, 63, 62, 63, 64, 65, 66, 65, 66, 67, 68, 69, 68, 69, 70, 71, 72, 71, 72, 73, 74, 75, 74, 75, 76, 77, 78, 77, 78, 79, 80, 81, 80, 81, 82, 83, 84, 83, 84, 85, 86, 87, 86, 87, 88, 89, 90, 89, 90, 91, 92, 93, 92, 93, 94, 95, 96, 95, 96, 97, 98, null, 98, 99, null, null, null),
            accordion_b_griff2  = Array(null, null, null, 49, 51, null, 48, 50, 52, 54, 49, 51, 53, 55, 57, 52, 54, 56, 58, 60, 55, 57, 59, 61, 63, 58, 60, 62, 64, 66, 61, 63, 65, 67, 69, 64, 66, 68, 70, 72, 67, 69, 71, 73, 75, 70, 72, 74, 76, 78, 73, 75, 77, 79, 81, 76, 78, 80, 82, 84, 79, 81, 83, 85, 87, 82, 84, 86, 88, 90, 85, 87, 89, 91, 93, 88, 90, 92, 94, 96, 91, 93, 95, 97, 99, 94, 96, 98, 100, null, 97, 99, null, null, null),
            accordions = Array(accordion_c_europe, accordion_c_griff2, accordion_b_bajan, accordion_b_finland, accordion_b_griff1, accordion_b_griff2),
            // Scales
            scale_major = Array(0, 2, 4, 5, 7, 9, 11),
            scale_minor = Array(0, 2, 3, 5, 7, 8, 10),
            scales = Array(scale_major, scale_minor),
            scales_txt = Array('', 'm');

        var e, i, x, y,
            but, key, black,
            midi, midi_oct, cursor, voice, scope,
            sum, sum_max, sum_r;

        // Count the notes
        midi = [];
        for (i=0; i<128; i++)
            midi.push(0);
        midi_oct = Array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        if (curScore != null) {
            scope = getScope();
            cursor = curScore.newCursor();
            cursor.staffIdx = 0;
            for (voice=0; voice<4; voice++) {
                cursor.voice = voice;
                cursor.rewind(Cursor.SCORE_START);
                while (cursor.segment) {
                    if (inScope(cursor, scope) && (e = cursor.element))
                        if (e.type == Element.CHORD)
                            for (i=0; i<e.notes.length; i++) {
                                if (e.notes[i].tieBack)            // Long note
                                    continue;
                                midi[e.notes[i].pitch]++;
                                midi_oct[e.notes[i].pitch % 12]++;
                            }
                    cursor.next();
                }
            }
        }

        // Layout
        for (x=0; x<5; x++) {
            for (y=0; y<19; y++) {
                i = y * 5 + x;
                but = buttons[i];
                key = accordions[id][i];
                if (key == null) {
                    but.parent.color = 'red';
                    but.text = '';
                    but.parent.visible = false;
                } else {
                    black = c_black[key % 12];
                    but.parent.border.width = (key % 12 == 0 ? 3 : 1);
                    if (midi[key] > 0) {
                        but.color = 'black';
                        but.parent.color = (black ? 'deepskyblue' : 'lightskyblue');
                        but.text = midi[key];
                        but.font.pointSize = 10;
                    } else {
                        but.color = (black ? 'white' : 'black');
                        but.parent.color = (black ? 'slategray' : 'white');
                        but.text = (qShowNotes.checked ? key2us(key) : '');
                        but.font.pointSize = 7;
                    }
                    but.parent.visible = true;
                }
            }
        }

        // Detection of the nearest scale
        sum_max = 0;
        sum_r = [];
        for (y=0; y<scales.length; y++) {                           // Scale
            for (x=0; x<12; x++) {                                  // Key
                sum = 0;
                for (i=0; i<scales[y].length; i++)
                    sum += midi_oct[(x + scales[y][i]) % 12];
                if (sum > sum_max)
                    sum_r = [];
                if ((sum > 0) && (sum >= sum_max)) {
                    sum_max = sum;
                    sum_r.push(c_keys_txt[x] + scales_txt[y]);
                }
            }
        }
        if (sum_max == 0)
            sum_r.push('-');
        else
            sum_r.sort();
        qScaleLabel.text = sum_r.join('  ');

        // Other determinations
        refreshFingering();
        refreshComplexChords();
        refreshHarmonization();
    }

    function refreshFingering() {
        var cursor, scope, timesigFactor, e, e2, i, n, f, p,
            keys, fingers, ticks, errmsg,
            hand;

        // Map the keys and fingers
        keys = [];
        fingers = [];
        ticks = [];
        errmsg = '';
        if (curScore != null) {
            scope = getScope();
            cursor = curScore.newCursor();
            cursor.staffIdx = 0;
            cursor.voice = 0;
            cursor.rewind(Cursor.SCORE_START);
            timesigFactor = cursor.measure.timesigActual.numerator / cursor.measure.timesigActual.denominator;
            while (cursor.segment) {
                if (inScope(cursor, scope) && (e = cursor.element))
                    if (e.type == Element.CHORD) {
                        // Key
                        if (e.notes.length != 1) {
                            errmsg = 'Chords are not supported';
                            break;
                        }
                        e2 = e.notes[0];
                        keys.push(e2.pitch);
                        ticks.push(Math.floor(cursor.tick / (4 * timesigFactor * division)) + 1);

                        // Finger
                        n = 0;
                        for (i=0; i<e2.elements.length; i++) {
                            if (e2.elements[i].type == Element.FINGERING) {
                                f = parseInt(e2.elements[i].text.substring(0, 1));
                                if (isNaN(f) || (f < 1) || (f > 5))
                                    errmsg = 'Wrong finger identifier';
                                else
                                    n++;
                            }
                        }
                        if (n == 0)
                            fingers.push(0);
                        else if (n == 1)
                            fingers.push(f);
                        else
                            errmsg = 'Multiple fingering for a key';
                        if (errmsg.length > 0)
                            break;
                    }
                cursor.next();
            }
        }

        // Detect the inconsistencies
        if ((errmsg.length == 0) && (keys.length > 0) && (keys.length == fingers.length)) {
            hand = Array(-1, -1, -1, -1, -1, -1);
            for (i=0; i<keys.length; i++) {
                p = hand.indexOf(keys[i]);
                if (fingers[i] != 0) {                                                  // With finger mark
                    if (!qFingeringRedundantCheckbox.checked && (p != -1) && (p == fingers[i])) {
                        errmsg = 'Redundant finger for '+key2us(keys[i])+' on segment '+ticks[i];
                        break;
                    }
                    hand = hand.map(function(e) { return (e == keys[i] ? -1 : e) });    // Release key
                    hand[fingers[i]] = keys[i];                                         // Press key
                } else {                                                                // Without finger mark
                    if (p == -1) {
                        errmsg = 'Missing finger for '+key2us(keys[i])+' on segment '+ticks[i];
                        break;
                    }
                }
            }
        }

        // Final analysis
        if (errmsg == '')
            errmsg = 'No error found';
        qFingeringLabel.text = errmsg;
    }

    function refreshComplexChords() {
        var e, base, key, chord, tmp, result, case1, case2, case3;

        function _key2str(key, single) {
            var result = (curScore.keysig < 0 ? c_flatkeys_txt : c_keys_txt)[key % 12];
            return (single ? result.toLowerCase() : result);
        }

        // Detect the chord
        result = '';
        if ((curScore != null) && (curScore.selection.elements.length == 1)) {
            e = curScore.selection.elements[0];
            if (e.type == Element.HARMONY) {
                tmp = reduceChordNotation(e.text);
                base = tmp.substr(0, 1);
                chord = tmp.substr(1);
                tmp = chord.substr(0, 1);
                if ((tmp == '♯') || (tmp == 'b')) {
                    base += tmp;
                    chord = chord.substr(1);
                }
                key = c_keys_txt.indexOf(base);
                if (key == -1)
                    key = c_flatkeys_txt.indexOf(base);
                if (key != -1) {
                    tmp = chord.indexOf('/');
                    if (tmp != -1)
                        chord = chord.substr(0, tmp);

                    // Expand the chord
                    case1 = ['no information'];
                    case2 = [];
                    case3 = [];
                    switch (chord) {
                        case 'dim': // 0 3 6
                            case1 = ['standard chord'];
                            break;

                        case 'dim7': // 0 3 6 9
                            case1 = [_key2str(key, true), _key2str(key+6, false)+'dim'];        // Second note transposed from dim7
                            case2 = [_key2str(key+6, true), _key2str(key, false)+'dim'];        // Third note as bass
                            break;

                        case 'm7b5': // 0 3 6 10
                            case1 = [_key2str(key, true), _key2str(key+3, false)+'m'];
                            break;

                        case 'm': // 0 3 7
                            case1 = ['standard chord'];
                            break;

                        case 'm6': // 0 3 7 9
                            case1 = [_key2str(key, false)+'m', _key2str(key+9, true)];          // Fourth note as bass
                            break;

                        case 'm7': // 0 3 7 10
                            case1 = [_key2str(key, true), _key2str(key+3, false)];
                            case2 = [_key2str(key, false)+'m', _key2str(key+3, false)];
                            break;

                        case 'm7b9': // 0 3 7 10 13
                            case1 = [_key2str(key, false)+'m', _key2str(key+10, false)+'dim'];
                            break;

                        case 'm9': // 0 3 7 10 14
                            case1 = [_key2str(key, false)+'m', _key2str(key+7, false)+'m'];
                            case2 = [_key2str(key, true), _key2str(key+7, false)+'m'];          // With optional minor
                            break;

                        case 'm11': // 0 3 7 10 14 17
                            case1 = [_key2str(key, false)+'m', _key2str(key+10, false)];
                            break;

                        case 'mM9': // 0 3 7 11 14
                        case 'm9M7':
                            case1 = [_key2str(key, false)+'m', _key2str(key+7, false)];
                            case2 = [_key2str(key, true), _key2str(key+7, false)];              // With optional minor
                            break;

                        case 'mM7add13': // 0 3 7 11 21
                            case1 = [_key2str(key, false)+'m', _key2str(key+11, false)+'7'];    // Several transpositions
                            break;

                        case '7b5': // 0 4 6 10
                            case1 = [_key2str(key, false)+'7', _key2str(key+6, false)+'7'];
                            case2 = [_key2str(key, true), _key2str(key+6, false)+'7'];          // Second note transposed from 7
                            case3 = [_key2str(key, false)+'7', _key2str(key+6, true)];
                            break;

                        case '7b5b9': // 0 4 6 10 13
                            case1 = [_key2str(key, false)+'7', _key2str(key+6, false)];
                            break;

                        case '13b5b9': // 0 4 6 10 13 21
                            case1 = [_key2str(key, false)+'7', _key2str(key+6, false)+'m'];     // Sixth note transposed from Minor
                            break;

                        case '': // 0 4 7
                            case1 = ['standard chord'];
                            break;

                        case '6': // 0 4 7 9
                            case1 = [_key2str(key, false), _key2str(key+9, false)+'m'];
                            case2 = [_key2str(key, true), _key2str(key+9, false)+'m'];          // Transposed without 5th
                            break;

                        case '7': // 0 4 7 10
                            case1 = [_key2str(key, false), _key2str(key, false)+'7'];           // Third note from Major
                            case2 = [_key2str(key, true), _key2str(key+7, false)+'dim'];        // Second note transposed from dim7
                            case3 = [_key2str(key, false)+'7', _key2str(key+7, true)];          // Third note as bass
                            break;

                        case '7b9': // 0 4 7 10 13
                            case1 = [_key2str(key, false), _key2str(key+10, false)+'dim'];
                            case2 = [_key2str(key, true), _key2str(key+10, false)+'dim'];       // With optional major
                            case3 = [_key2str(key, false)+'7', _key2str(key+4, false)+'dim'];
                            break;

                        case '11b9': // 0 4 7 10 13 17
                            case1 = [_key2str(key, false), _key2str(key+10, false)+'m'];
                            case2 = [_key2str(key, true), _key2str(key+10, false)+'m'];         // With optional major
                            break;

                        case '9': // 0 4 7 10 14
                        case '7add9':
                            case1 = [_key2str(key, false), _key2str(key+7, false)+'m'];
                            case2 = [_key2str(key, false)+'7', _key2str(key+7, false)+'m'];
                            case3 = [_key2str(key, true), _key2str(key+7, false)+'m'];          // With optional major
                            break;

                        case '11': // 0 4 7 10 14 17
                        case '9b11':
                            case1 = [_key2str(key, false), _key2str(key+10, false)];
                            case2 = [_key2str(key, true), _key2str(key+10, false)];             // With optional major
                            break;

                        case '9b13': // 0 4 7 10 14 20
                            case1 = [_key2str(key, false), _key2str(key+10, false)+'7'];
                            case2 = [_key2str(key, true), _key2str(key+10, false)+'7'];         // With optional major
                            break;

                        case '7♯9': // 0 4 7 10 15
                            case1 = [_key2str(key, false), _key2str(key+15, false)];            // Fourth note transposed from second Major
                            break;

                        case 'M7': // 0 4 7 11
                            case1 = [_key2str(key, false), _key2str(key+4, false)+'m'];
                            break;

                        case 'M9': // 0 4 7 11 14
                            case1 = [_key2str(key, false), _key2str(key+7, false)];
                            case2 = [_key2str(key, true), _key2str(key+7, false)];              // With optional major
                            break;
                            
                        case 'M11': // 0 4 7 11 14 17
                        case 'M9b11':
                            case1 = [_key2str(key, false), _key2str(key+7, false), _key2str(key+7, false)+'7'];
                            break;
                            
                        case 'M9♯11': // 0 4 7 11 14 18
                            case1 = [_key2str(key, false), _key2str(key+11, false)+'m'];
                            case2 = [_key2str(key, true), _key2str(key+11, false)+'m'];         // With optional major
                            break;

                        case '7♯5': // 0 4 8 10
                            case1 = [_key2str(key, false)+'7', _key2str(key+8, true)];          // Third note as bass
                            break;

                        case 'M7♯5': // 0 4 8 11
                            case1 = [_key2str(key, true), _key2str(key+4, false)];
                            break;

                        case 'M9♯5': // 0 4 8 11 14
                            case1 = [_key2str(key, true), _key2str(key+4, false), _key2str(key+4, false)+'7'];
                            break;

                        case '9sus': // 0 5 (7) 10 14
                        case '9sus4':
                            case1 = [_key2str(key, true), _key2str(key+10, false)];             // Without 5th (impossible), second note transposed
                            break;
                    }

                    // Format the result
                    result = base + chord + ' = ' + (case1.join(' + '));
                    if (case2.length > 0)
                        result += ', ' + (case2.join(' + '));
                    if (case3.length > 0)
                        result += ', ' + (case3.join(' + '));
                }
            }
        }
        qComplexChordLabel.text = result;
        refreshChordsOnScore();
    }

    function refreshChordsOnScore() {
        var cursor, scope, i, e, txt, p,
            chords = [];
        
        if ((curScore == null) || (qComplexChordLabel.text.length > 0))
            return false;

        // Read all the available chords
        scope = getScope();
        cursor = curScore.newCursor();
        cursor.staffIdx = 0;
        cursor.voice = 0;
        cursor.rewind(Cursor.SCORE_START);
        while (cursor.segment) {
            if (inScope(cursor, scope)) {
                e = cursor.segment.annotations;
                for (i=0; i<e.length ; i++) {
                    if (e[i].type == Element.HARMONY) {
                        txt = reduceChordNotation(e[i].text);
                        p = txt.indexOf('/');
                        if (p != -1)
                            txt = txt.substr(0, p);
                        if ((chords.indexOf(txt) == -1) && (txt.toUpperCase() != 'NC'))
                            chords.push(txt);
                    }
                }
            }
            cursor.next();
        }

        // Show the chords
        chords.sort();
        qComplexChordLabel.text = (chords.length == 0 ? 'No harmony' : chords.join(' '));
        return true;
    }

    function refreshHarmonization(selectedKeys) {
        var key, selchords, possible;

        function _key_repr(key, scale) {
            var s = (curScore.keysig < 0 ? c_flatkeys_txt : c_keys_txt)[(key + 12) % 12] + scale;
            if (selchords.indexOf(s) == -1)
                selchords.push(s);
        }

        // Check
        if ((curScore == null) ||
            (curScore.selection.elements.length != 1) ||
            (curScore.selection.elements[0].type != Element.NOTE)) {
            qHarmonizationSolutionLabel.text = '';
            qHarmonizationAllLabel1.text = '';
            qHarmonizationAllLabel2.text = '';
            return false;
        }

        // Find the chords
        key = curScore.selection.elements[0].pitch;
        selchords = [];
        _key_repr(key, '');             // Major
        _key_repr(key-4, '');
        _key_repr(key-7, '');
        _key_repr(key-10, '');
        _key_repr(key, 'm');            // Minor
        _key_repr(key-3, 'm');
        _key_repr(key-7, 'm');
        _key_repr(key, '7');            // Dominant seventh
        _key_repr(key-4, '7');
        _key_repr(key-7, '7');
        _key_repr(key-10, '7');
        _key_repr(key, 'dim');          // Diminished
        _key_repr(key-3, 'dim');
        _key_repr(key-6, 'dim');

        // Key signature
        switch (curScore.keysig) {
            case -7: possible = Array('B',  'Dbm', 'Ebm', 'E',  'Gb', 'Abm', 'Bbdim'); break;  // Cb Ab
            case -6: possible = Array('Gb', 'Abm', 'Bbm', 'B',  'Db', 'Ebm', 'Fdim');  break;  // Gb Eb
            case -5: possible = Array('Db', 'Ebm', 'Fm',  'Gb', 'Ab', 'Bbm', 'Cdim');  break;  // Db Bb
            case -4: possible = Array('Ab', 'Bbm', 'Cm',  'Db', 'Eb', 'Fm',  'Gdim');  break;  // Ab F
            case -3: possible = Array('Eb', 'Fm',  'Gm',  'Ab', 'Bb', 'Cm',  'Ddim');  break;  // Eb C
            case -2: possible = Array('Bb', 'Cm',  'Dm',  'Eb', 'F',  'Gm',  'Adim');  break;  // Bb G
            case -1: possible = Array('F',  'Gm',  'Am',  'Bb', 'C',  'Dm',  'Edim');  break;  // F  D
            case  0: possible = Array('C',  'Dm',  'Em',  'F',  'G',  'Am',  'Bdim');  break;  // C  A
            case  1: possible = Array('G',  'Am',  'Bm',  'C',  'D',  'Em',  'F♯dim'); break;  // G  E
            case  2: possible = Array('D',  'Em',  'F♯m', 'G',  'A',  'Bm',  'C♯dim'); break;  // D  B
            case  3: possible = Array('A',  'Bm',  'C♯m', 'D',  'E',  'F♯m', 'G♯dim'); break;  // A  F♯
            case  4: possible = Array('E',  'F♯m', 'G♯m', 'A',  'B',  'C♯m', 'D♯dim'); break;  // E  C♯
            case  5: possible = Array('B',  'C♯m', 'D♯m', 'E',  'F♯', 'G♯m', 'A♯dim'); break;  // B  G♯
            case  6: possible = Array('F♯', 'G♯m', 'A♯m', 'B',  'C♯', 'D♯m', 'Fdim');  break;  // F♯ D♯
            case  7: possible = Array('C♯', 'D♯m', 'Fm',  'F♯', 'G♯', 'A♯m', 'Cdim');  break;  // C♯ A♯
            default: return false;
        }

        // Result
        qHarmonizationSolutionLabel.text = possible.filter(function(e) { return selchords.indexOf(e) != -1 }).join('  ');
        selchords.sort();
        qHarmonizationAllLabel1.text = selchords.slice(0, 7).join('  ');
        qHarmonizationAllLabel2.text = selchords.slice(7).join('  ');
        return true;
    }


    //=============================================================================
    // QT elements

    Rectangle {
        id: mainArea

        Label {
            id: qLayoutLabel
            x: 10
            y: 15
            text: "Layout:"
            font.bold: true
        }

        ComboBox {
            id: qLayout
            x: 70
            y: 10
            width: 120

            model: ListModel {
                id: model
                ListElement { text: "C-griff Europe" }
                ListElement { text: "C-griff 2" }
                ListElement { text: "B-griff Bajan" }
                ListElement { text: "B-griff Finland" }
                ListElement { text: "D-griff 1" }
                ListElement { text: "D-griff 2" }
            }
            onActivated: refreshAccordion(index)
        }

        CheckBox {
            id: qShowNotes
            x: 10
            y: 40
            checked: true
            text: "Show the keys"
            onClicked: refreshAccordion(qLayout.currentIndex)
        }

        // ---

        Label {
            x: 10
            y: 530
            text: "Scales:"
            font.bold: true
        }

        Label {
            id: qScaleLabel
            x: 70
            y: 530
        }

        // ---

        Label {
            x: 10
            y: 565
            text: "Fingering:"
            font.bold: true
        }

        Label {
            id: qFingeringLabel
            x: 10
            y: 585
        }

        CheckBox {
            id: qFingeringRedundantCheckbox
            x: 10
            y: 605
            text: "Allowed redundancies"
        }

        // ---

        Label {
            x: 10
            y: 645
            text: "Detailed chords:"
            font.bold: true
        }

        Label {
            id: qComplexChordLabel
            x: 10
            y: 665
        }

        // ---

        Label {
            x: 10
            y: 700
            text: "Harmonization:"
            font.bold: true
        }

        Label {
            id: qHarmonizationSolutionLabel
            x: 130
            y: 700
        }

        Label {
            x: 10
            y: 720
            text: "- All:"
            font.bold: true
        }

        Label {
            id: qHarmonizationAllLabel1
            x: 50
            y: 720
        }

        Label {
            id: qHarmonizationAllLabel2
            x: 50
            y: 740
        }

        // ---

        Timer {
            id: qTimer
            interval: 3000
            running: true
            repeat: true
            onTriggered: refreshAccordion(qLayout.currentIndex)
        }
    }
}
