//=============================================================================
// Chromatic button accordion, right hand - Plugin for MuseScore
// Copyright © 2023 Alexandre Bréard
// Homepage: https://github.com/gitbra/ChromaticButtonAccordionRight
// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//=============================================================================
// https://musescore.org/en/handbook/developers-handbook/plugins-3x
// https://musescore.org/en/developers-handbook/references/musescore-internal-score-representation
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/index.html
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/class_ms_1_1_plugin_a_p_i_1_1_plugin_a_p_i.html
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/annotated.html
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/namespace_ms.html#a16b11be27a8e9362dd122c4d879e01ae
// https://doc.qt.io/archives/qt-5.9/qmltypes.html
// https://static.roland.com/assets/media/pdf/FR-1x_e02_W.pdf
//=============================================================================

import QtQuick 2.2
import QtQuick.Controls 1.1
import MuseScore 3.0

MuseScore {

    //=============================================================================
    // Meta info

    version: "0.2"
    description: "Transform a track into a visual chromatic button accordion (6 layouts). Locate your right buttons at glance"
    menuPath: "Plugins.ChromaticButtonAccordionRight"
    requiresScore: true

    id: mainapp
    pluginType: "dock"
    dockArea: "right"
    width: 200
    height: 535
    
    property var buttons: []


    //=============================================================================
    // Main loop

    onRun: {
        // Check
        if (typeof curScore === 'undefined')
            Qt.quit();

        // Basic layout
        var x, y, but;
        for (y=0; y<19; y++) {
            for (x=0; x<5; x++) {
                but = Qt.createQmlObject('import QtQuick 2.2; Rectangle {width:30; height:20; visible:true; border.color:"black"; Text {anchors.centerIn:parent}}', mainArea);
                but.x = 35 * x + 10;
                but.y = 25 * (y - 1) + 10 * x + 65;
                buttons.push(Qt.createQmlObject('import QtQuick 2.2; Text {anchors.centerIn:parent}', but));
            }
        }
        refreshAccordion(qLayout.currentIndex);
    }


    //=============================================================================
    // Computation

    function midi2black(key) {
        return Array(false, true, false, true, false, false, true, false, true, false, true, false)[(key||0) % 12];
    }

    function midi2key(key) {
        return Array('C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B')[key % 12] + (Math.floor(key / 12) - 1);
    }

    function refreshAccordion(id) {
        // Types of accordions
        var accordion_c_europe  = Array(null, null, null, 48, 49, null, 49, 50, 51, 52, 51, 52, 53, 54, 55, 54, 55, 56, 57, 58, 57, 58, 59, 60, 61, 60, 61, 62, 63, 64, 63, 64, 65, 66, 67, 66, 67, 68, 69, 70, 69, 70, 71, 72, 73, 72, 73, 74, 75, 76, 75, 76, 77, 78, 79, 78, 79, 80, 81, 82, 81, 82, 83, 84, 85, 84, 85, 86, 87, 88, 87, 88, 89, 90, 91, 90, 91, 92, 93, 94, 93, 94, 95, 96, 97, 96, 97, 98, 99, null, 99, 100, null, null, null),
            accordion_c_griff2  = Array(null, null, null, 51, 53, null, 50, 52, 54, 56, 51, 53, 55, 57, 59, 54, 56, 58, 60, 62, 57, 59, 61, 63, 65, 60, 62, 64, 66, 68, 63, 65, 67, 69, 71, 66, 68, 70, 72, 74, 69, 71, 73, 75, 77, 72, 74, 76, 78, 80, 75, 77, 79, 81, 83, 78, 80, 82, 84, 86, 81, 83, 85, 87, 89, 84, 86, 88, 90, 92, 87, 89, 91, 93, 95, 90, 92, 94, 96, 98, 93, 95, 97, 99, 101, 96, 98, 100, 102, null, 99, 101, null, null, null),
            accordion_b_bajan   = Array(null, null, null, 50, 52, null, 49, 51, 53, 55, 50, 52, 54, 56, 58, 53, 55, 57, 59, 61, 56, 58, 60, 62, 64, 59, 61, 63, 65, 67, 62, 64, 66, 68, 70, 65, 67, 69, 71, 73, 68, 70, 72, 74, 76, 71, 73, 75, 77, 79, 74, 76, 78, 80, 82, 77, 79, 81, 83, 85, 80, 82, 84, 86, 88, 83, 85, 87, 89, 91, 86, 88, 90, 92, 94, 89, 91, 93, 95, 97, 92, 94, 96, 98, 100, 95, 97, 99, 101, null, 98, 100, null, null, null),
            accordion_b_finland = Array(null, null, null, 49, 50, null, 50, 51, 52, 53, 52, 53, 54, 55, 56, 55, 56, 57, 58, 59, 58, 59, 60, 61, 62, 61, 62, 63, 64, 65, 64, 65, 66, 67, 68, 67, 68, 69, 70, 71, 70, 71, 72, 73, 74, 73, 74, 75, 76, 77, 76, 77, 78, 79, 80, 79, 80, 81, 82, 83, 82, 83, 84, 85, 86, 85, 86, 87, 88, 89, 88, 89, 90, 91, 92, 91, 92, 93, 94, 95, 94, 95, 96, 97, 98, 97, 98, 99, 100, null, 100, 101, null, null, null),
            accordion_b_griff1  = Array(null, null, null, null, 48, null, 48, 49, 50, 51, 50, 51, 52, 53, 54, 53, 54, 55, 56, 57, 56, 57, 58, 59, 60, 59, 60, 61, 62, 63, 62, 63, 64, 65, 66, 65, 66, 67, 68, 69, 68, 69, 70, 71, 72, 71, 72, 73, 74, 75, 74, 75, 76, 77, 78, 77, 78, 79, 80, 81, 80, 81, 82, 83, 84, 83, 84, 85, 86, 87, 86, 87, 88, 89, 90, 89, 90, 91, 92, 93, 92, 93, 94, 95, 96, 95, 96, 97, 98, null, 98, 99, null, null, null),
            accordion_b_griff2  = Array(null, null, null, 49, 51, null, 48, 50, 52, 54, 49, 51, 53, 55, 57, 52, 54, 56, 58, 60, 55, 57, 59, 61, 63, 58, 60, 62, 64, 66, 61, 63, 65, 67, 69, 64, 66, 68, 70, 72, 67, 69, 71, 73, 75, 70, 72, 74, 76, 78, 73, 75, 77, 79, 81, 76, 78, 80, 82, 84, 79, 81, 83, 85, 87, 82, 84, 86, 88, 90, 85, 87, 89, 91, 93, 88, 90, 92, 94, 96, 91, 93, 95, 97, 99, 94, 96, 98, 100, null, 97, 99, null, null, null),
            accordions = Array(accordion_c_europe, accordion_c_griff2, accordion_b_bajan, accordion_b_finland, accordion_b_griff1, accordion_b_griff2);

        var e, i, x, y,
            but, key, black,
            midi, cursor, voice;

        // Count the notes
        midi = Array();
        for (i=0; i<128 ; i++)
            midi.push(0);
        if (curScore != null) {
            cursor = curScore.newCursor();
            cursor.staffIdx = 0;
            for (voice=0; voice<4; voice++) {
                cursor.voice = voice;
                cursor.rewind(Cursor.SCORE_START);
                while (cursor.segment) {
                    if (e = cursor.element)
                        if (e.type == Element.CHORD)
                            for (i=0; i<e.notes.length; i++)
                                midi[e.notes[i].pitch]++;
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
                    black = midi2black(key);
                    but.parent.border.width = (key % 12 == 0 ? 3 : 1);
                    if (midi[key] > 0) {
                        but.color = 'black';
                        but.parent.color = (black ? 'deepskyblue' : 'lightskyblue');
                        but.text = midi[key];
                        but.font.pointSize = 10;
                    } else {
                        but.color = (black ? 'white' : 'black');
                        but.parent.color = (black ? 'slategray' : 'white');
                        but.text = (qShowNotes.checked ? midi2key(key) : '');
                        but.font.pointSize = 7;
                    }
                    but.parent.visible = true;
                }
            }
        }
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
            x: 60
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

        Timer {
            id: qTimer
            interval: 5000
            running: true
            repeat: true
            onTriggered: refreshAccordion(qLayout.currentIndex)
        }
    }
}
