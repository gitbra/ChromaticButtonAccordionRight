//=============================================================================
// Chromatic button accordion, right hand - Plugin for MuseScore
// Copyright © 2023 Alexandre Bréard
// Homepage: https://github.com/gitbra/ChromaticButtonAccordionRight
// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//=============================================================================
// https://musescore.org/en/handbook/developers-handbook/plugins-3x
// https://musescore.org/en/developers-handbook/references/musescore-internal-score-representation
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/class_ms_1_1_plugin_a_p_i_1_1_plugin_a_p_i.html
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/annotated.html
// https://musescore.github.io/MuseScore_PluginAPI_Docs/plugins/html/namespace_ms.html#a16b11be27a8e9362dd122c4d879e01ae
// https://doc.qt.io/archives/qt-5.9/qmltypes.html
//=============================================================================

import QtQuick 2.2
import MuseScore 3.0

MuseScore {

    //=============================================================================
    // Meta info

    version: "0.1"
    description: "Transform a track into a visual chromatic C-griff Europe button accordion. Locate your right buttons at glance"
    menuPath: "Plugins.ChromaticButtonAccordionRight"
    requiresScore: true

    pluginType: "dialog"
    width: 200
    height: 450

    //=============================================================================
    // Core

    onRun: {
        // Check
        if (typeof curScore === 'undefined')
            Qt.quit();

        // Variables
        const midi_max = 128;
        var e, i, midi, voice;
        midi = Array();
        for (i=0; i<midi_max ; i++)
            midi.push(0);

        // Walk-through
        var cursor = curScore.newCursor();
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

        /*// Debug
        for (i=0; i<midi_max; i++)
            console.log(i + " = " & midi[i]);
        //*/

        // Update the buttons
        function button_mapper(components, lambda) {
            var i;
            for (i=0; i<components.length; i++)
                if (midi[lambda(i)] > 0) {
                    components[i].text = midi[lambda(i)];
                    components[i].parent.color = "aqua";
                }
        }
        button_mapper(Array(c3, cd3, d3, dd3, e3, f3, fd3, g3, gd3, a3, ad3, b3,
                            c4, cd4, d4, dd4, e4, f4, fd4, g4, gd4, a4, ad4, b4,
                            c5, cd5, d5, dd5, e5, f5, fd5, g5, gd5, a5, ad5, b5,
                            c6, cd6, d6, dd6, e6, f6, fd6, g6, gd6, a6, ad6, b6,
                            c7, cd7, d7),
                      function(i) { return 48 + i; });
        button_mapper(Array(dd3_4, fd3_4, a3_4,
                            c4_4, dd4_4, fd4_4, a4_4,
                            c5_4, dd5_4, fd5_4, a5_4,
                            c6_4, dd6_4, fd6_4, a6_4,
                            c7_4, dd7_4),
                      function(i) { return 51 + 3*i; });
        button_mapper(Array(cd3_5, e3_5, g3_5, ad3_5,
                            cd4_5, e4_5, g4_5, ad4_5,
                            cd5_5, e5_5, g5_5, ad5_5,
                            cd6_5, e6_5, g6_5, ad6_5,
                            cd7_5, e7_5),
                      function(i) { return 49 + 3*i; });
    }

    //=============================================================================
    // Static UI

	Rectangle {color:"gray";  width:30; height:20; x:150; y: 15; visible:true;  border.color:"black"; border.width:1; Text {id:"cd3_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y:  0; visible:false; border.color:"black"; border.width:3; Text {id:"c3"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y: 10; visible:true;  border.color:"black"; border.width:1; Text {id:"cd3"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y: 20; visible:true;  border.color:"black"; border.width:1; Text {id:"d3"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y: 30; visible:true;  border.color:"black"; border.width:1; Text {id:"dd3_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y: 40; visible:true;  border.color:"black"; border.width:1; Text {id:"e3_5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 10; y: 25; visible:true;  border.color:"black"; border.width:1; Text {id:"dd3"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 45; y: 35; visible:true;  border.color:"black"; border.width:1; Text {id:"e3"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y: 45; visible:true;  border.color:"black"; border.width:1; Text {id:"f3"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y: 55; visible:true;  border.color:"black"; border.width:1; Text {id:"fd3_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y: 65; visible:true;  border.color:"black"; border.width:1; Text {id:"g3_5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 10; y: 50; visible:true;  border.color:"black"; border.width:1; Text {id:"fd3"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 45; y: 60; visible:true;  border.color:"black"; border.width:1; Text {id:"g3"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 80; y: 70; visible:true;  border.color:"black"; border.width:1; Text {id:"gd3"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:115; y: 80; visible:true;  border.color:"black"; border.width:1; Text {id:"a3_4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:150; y: 90; visible:true;  border.color:"black"; border.width:1; Text {id:"ad3_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y: 75; visible:true;  border.color:"black"; border.width:1; Text {id:"a3"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y: 85; visible:true;  border.color:"black"; border.width:1; Text {id:"ad3"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y: 95; visible:true;  border.color:"black"; border.width:1; Text {id:"b3"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:115; y:105; visible:true;  border.color:"black"; border.width:3; Text {id:"c4_4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:150; y:115; visible:true;  border.color:"black"; border.width:1; Text {id:"cd4_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y:100; visible:true;  border.color:"black"; border.width:3; Text {id:"c4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y:110; visible:true;  border.color:"black"; border.width:1; Text {id:"cd4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:120; visible:true;  border.color:"black"; border.width:1; Text {id:"d4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y:130; visible:true;  border.color:"black"; border.width:1; Text {id:"dd4_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y:140; visible:true;  border.color:"black"; border.width:1; Text {id:"e4_5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 10; y:125; visible:true;  border.color:"black"; border.width:1; Text {id:"dd4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 45; y:135; visible:true;  border.color:"black"; border.width:1; Text {id:"e4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:145; visible:true;  border.color:"black"; border.width:1; Text {id:"f4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y:155; visible:true;  border.color:"black"; border.width:1; Text {id:"fd4_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y:165; visible:true;  border.color:"black"; border.width:1; Text {id:"g4_5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 10; y:150; visible:true;  border.color:"black"; border.width:1; Text {id:"fd4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 45; y:160; visible:true;  border.color:"black"; border.width:1; Text {id:"g4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 80; y:170; visible:true;  border.color:"black"; border.width:1; Text {id:"gd4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:115; y:180; visible:true;  border.color:"black"; border.width:1; Text {id:"a4_4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:150; y:190; visible:true;  border.color:"black"; border.width:1; Text {id:"ad4_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y:175; visible:true;  border.color:"black"; border.width:1; Text {id:"a4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y:185; visible:true;  border.color:"black"; border.width:1; Text {id:"ad4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:195; visible:true;  border.color:"black"; border.width:1; Text {id:"b4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:115; y:205; visible:true;  border.color:"black"; border.width:3; Text {id:"c5_4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:150; y:215; visible:true;  border.color:"black"; border.width:1; Text {id:"cd5_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y:200; visible:true;  border.color:"black"; border.width:3; Text {id:"c5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y:210; visible:true;  border.color:"black"; border.width:1; Text {id:"cd5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:220; visible:true;  border.color:"black"; border.width:1; Text {id:"d5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y:230; visible:true;  border.color:"black"; border.width:1; Text {id:"dd5_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y:240; visible:true;  border.color:"black"; border.width:1; Text {id:"e5_5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 10; y:225; visible:true;  border.color:"black"; border.width:1; Text {id:"dd5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 45; y:235; visible:true;  border.color:"black"; border.width:1; Text {id:"e5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:245; visible:true;  border.color:"black"; border.width:1; Text {id:"f5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y:255; visible:true;  border.color:"black"; border.width:1; Text {id:"fd5_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y:265; visible:true;  border.color:"black"; border.width:1; Text {id:"g5_5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 10; y:250; visible:true;  border.color:"black"; border.width:1; Text {id:"fd5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 45; y:260; visible:true;  border.color:"black"; border.width:1; Text {id:"g5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 80; y:270; visible:true;  border.color:"black"; border.width:1; Text {id:"gd5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:115; y:280; visible:true;  border.color:"black"; border.width:1; Text {id:"a5_4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:150; y:290; visible:true;  border.color:"black"; border.width:1; Text {id:"ad5_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y:275; visible:true;  border.color:"black"; border.width:1; Text {id:"a5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y:285; visible:true;  border.color:"black"; border.width:1; Text {id:"ad5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:295; visible:true;  border.color:"black"; border.width:1; Text {id:"b5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:115; y:305; visible:true;  border.color:"black"; border.width:3; Text {id:"c6_4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:150; y:315; visible:true;  border.color:"black"; border.width:1; Text {id:"cd6_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y:300; visible:true;  border.color:"black"; border.width:3; Text {id:"c6"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y:310; visible:true;  border.color:"black"; border.width:1; Text {id:"cd6"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:320; visible:true;  border.color:"black"; border.width:1; Text {id:"d6"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y:330; visible:true;  border.color:"black"; border.width:1; Text {id:"dd6_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y:340; visible:true;  border.color:"black"; border.width:1; Text {id:"e6_5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 10; y:325; visible:true;  border.color:"black"; border.width:1; Text {id:"dd6"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 45; y:335; visible:true;  border.color:"black"; border.width:1; Text {id:"e6"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:345; visible:true;  border.color:"black"; border.width:1; Text {id:"f6"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y:355; visible:true;  border.color:"black"; border.width:1; Text {id:"fd6_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y:365; visible:true;  border.color:"black"; border.width:1; Text {id:"g6_5"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 10; y:350; visible:true;  border.color:"black"; border.width:1; Text {id:"fd6"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 45; y:360; visible:true;  border.color:"black"; border.width:1; Text {id:"g6"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 80; y:370; visible:true;  border.color:"black"; border.width:1; Text {id:"gd6"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:115; y:380; visible:true;  border.color:"black"; border.width:1; Text {id:"a6_4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:150; y:390; visible:true;  border.color:"black"; border.width:1; Text {id:"ad6_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y:375; visible:true;  border.color:"black"; border.width:1; Text {id:"a6"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y:385; visible:true;  border.color:"black"; border.width:1; Text {id:"ad6"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:395; visible:true;  border.color:"black"; border.width:1; Text {id:"b6"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:115; y:405; visible:true;  border.color:"black"; border.width:3; Text {id:"c7_4"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:150; y:415; visible:false; border.color:"black"; border.width:1; Text {id:"cd7_5"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 10; y:400; visible:true;  border.color:"black"; border.width:3; Text {id:"c7"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x: 45; y:410; visible:true;  border.color:"black"; border.width:1; Text {id:"cd7"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x: 80; y:420; visible:false; border.color:"black"; border.width:1; Text {id:"d7"; anchors.centerIn:parent}}
	Rectangle {color:"gray";  width:30; height:20; x:115; y:430; visible:false; border.color:"black"; border.width:1; Text {id:"dd7_4"; anchors.centerIn:parent}}
	Rectangle {color:"white"; width:30; height:20; x:150; y:440; visible:false; border.color:"black"; border.width:1; Text {id:"e7_5"; anchors.centerIn:parent}}
}
