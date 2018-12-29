//
//  Serialization.swift
//  mesher
//
//  Created by Eric O'Connell on 12/29/18.
//  Copyright © 2018 Eric O'Connell. All rights reserved.
//

import Foundation

//- Instance tree

struct Node : Codable {
    var mtype: String
    
    var childs: [Node]
    var id: Int
    var pathid: String
    var type: String
    var polys: Int
    var fragments: [Int]
    var materials: [Int]
}

struct Vector3 : Codable {
    var XYZ: [Float]
}

struct BoundingBox : Codable {
    var minXYZ: [Float]
    var maxXYZ: [Float]
}

struct Matrix : Codable {
    var mtype: String
}

struct Metadata : Codable {
    var angleToTrueNorth: Int
    var doubleSided: Bool
    var positionLL84: Vector3
    var refPointLMV: Vector3
    var refPointTransform: Int
    var units: String
    var viewToModelTransform: Matrix
    var worldBoundingBox: BoundingBox
    var worldNorthVector: Vector3
    var worldUpVector: Vector3
}

/*
{
    "childs": [
    {
    "childs": null,
    "id": 0,
    "mtype": "Identity",
    "pathid": "0",
    "polys": 0,
    "type": "Transform"
    },
    {
    "childs": [
    {
    "fragPolys": [
    58
    ],
    "fragments": [
    51
    ],
    "id": 12425,
    "materials": [
    2
    ],
    "mtype": "Identity",
    "pathid": "1:0",
    "polys": 58,
    "type": "Mesh"
    },
    {
    "fragPolys": [
    4
    ],
    "fragments": [
    6907
    ],
    "id": 12425,
    "materials": [
    3
    ],
    "mtype": "Identity",
    "pathid": "1:1",
    "polys": 4,
    "type": "Mesh"
    }
    ],
    "id": 12425,
    "mtype": "Identity",
    "pathid": "1",
    "polys": 62,
    "type": "Transform"
    },
    {
    "childs": [
    {
    "fragPolys": [
    12
    ],
    "fragments": [
    107
    ],
    "id": 12430,
    "materials": [
    2
    ],
    "mtype": "Identity",
    "pathid": "2:0",
    "polys": 12,
    "type": "Mesh"
    }
    ],
    "id": 12430,
    "mtype": "Identity",
    "pathid": "2",
    "polys": 12,
    "type": "Transform"
    },
    {
    "childs": [
    {
    "fragPolys": [
    8
    ],
    "fragments": [
    992
    ],
    "id": 12434,
    "materials": [
    4
    ],
    "mtype": "Identity",
    "pathid": "3:0",
    "polys": 8,
    "type": "Mesh"
    },
    {
    "fragPolys": [
    6
    ],
    "fragments": [
    987
    ],
    "id": 12434,
    "materials": [
    3
    ],
    "mtype": "Identity",
    "pathid": "3:1",
    "polys": 6,
    "type": "Mesh"
    },
    {
    "fragPolys": [
    36
    ],
    "fragments": [
    1754
    ],
    "id": 12434,
    "materials": [
    5
    ],
    "mtype": "Identity",
    "pathid": "3:2",
    "polys": 36,
    "type": "Mesh"
    }
    ],
    "id": 12434,
    "mtype": "Identity",
    "pathid": "3",
    "polys": 50,
    "type": "Transform"
    },
*/
 
//- Material

/*
{
    "version": 2,
    "userassets": [
    "0"
    ],
    "materials": {
        "0": {
            "tag": "",
            "proteinType": "",
            "definition": "SimplePhong",
            "properties": {
                "integers": {
                    "mode": 4
                },
                "booleans": {
                    "color_by_object": false,
                    "generic_is_metal": false,
                    "generic_backface_cull": true
                },
                "scalars": {
                    "generic_transparency": {
                        "units": "",
                        "values": [
                        0
                        ]
                    }
                },
                "colors": {
                    "generic_diffuse": {
                        "values": [
                        {
                        "r": 0.4,
                        "g": 0.4,
                        "b": 0.4,
                        "a": 1
                        }
                        ]
                    }
                }
            },
            "transparent": false,
            "textures": {}
        }
    }
}
*/


//- Properties

/*
 [
 {
 "id": 96677,
 "guid": "cd002d94-688a-4e12-a0de-279ca1190598-0048fce0",
 "props": [
 {
 "category": "__name__",
 "name": "name",
 "displayName": null,
 "type": 20,
 "value": "BAA_RECESSED FIRE EXTINGUISHER CABINET [4783328]",
 "unit": null,
 "hidden": false
 },
 {
 "category": "__category__",
 "name": "Category",
 "displayName": null,
 "type": 20,
 "value": "Revit Specialty Equipment",
 "unit": null,
 "hidden": true
 },
 {
 "category": "__categoryId__",
 "name": "CategoryId",
 "displayName": null,
 "type": 2,
 "value": -2001350,
 "unit": null,
 "hidden": true
 },
 {
 "category": "__instanceof__",
 "name": "instanceof_objid",
 "displayName": null,
 "type": 11,
 "value": 96666,
 "unit": null,
 "hidden": true
 },
 {
 "category": "__internalref__",
 "name": "Level",
 "displayName": null,
 "type": 11,
 "value": 3,
 "unit": null,
 "hidden": true
 },
 {
 "category": "Constraints",
 "name": "RO HT",
 "displayName": "",
 "type": 3,
 "value": 6,
 "unit": "ft",
 "hidden": false
 },
 {
 "category": "Constraints",
 "name": "Level",
 "displayName": "",
 "type": 20,
 "value": "UPPER LEVEL",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Constraints",
 "name": "Elevation",
 "displayName": "",
 "type": 3,
 "value": 6.00000000000003,
 "unit": "ft",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "TEXT",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "COMMENTS1",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "Finish Category",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "Finish Material Key",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "Finish Material Description",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "MB MARK",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "MB TYPE",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "PJ MARK",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "PJ TYPE",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "PJ CLG HT",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Text",
 "name": "PJ RUN OUT AT TOP",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Electrical - Loads",
 "name": "Panel",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Electrical - Loads",
 "name": "Circuit Number",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Identity Data",
 "name": "Type Name",
 "displayName": "",
 "type": 20,
 "value": "BAA_RECESSED FIRE EXTINGUISHER CABINET",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Identity Data",
 "name": "Specialty Equipment Style",
 "displayName": "",
 "type": 20,
 "value": "(none)",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Identity Data",
 "name": "Image",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Identity Data",
 "name": "Comments",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Identity Data",
 "name": "Mark",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Identity Data",
 "name": "Workset",
 "displayName": "",
 "type": 20,
 "value": "Workset1",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Identity Data",
 "name": "Edited by",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Phasing",
 "name": "Phase Created",
 "displayName": "",
 "type": 20,
 "value": "New Construction",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Phasing",
 "name": "Phase Demolished",
 "displayName": "",
 "type": 20,
 "value": "None",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Other",
 "name": "NUMBER",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Other",
 "name": "Finish Order",
 "displayName": "",
 "type": 20,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "Other",
 "name": "RECESSED",
 "displayName": "",
 "type": 1,
 "value": "",
 "unit": "",
 "hidden": false
 },
 {
 "category": "__viewable_in__",
 "name": "viewable_in",
 "displayName": null,
 "type": 20,
 "value": "623c5583-b1c6-4481-9309-7b3865651e25-000282d7",
 "unit": null,
 "hidden": true
 },
 {
 "category": "__category__",
 "name": "_RFT",
 "displayName": null,
 "type": 20,
 "value": "BAA_RECESSED FIRE EXTINGUISHER CABINET",
 "unit": null,
 "hidden": true
 },
 {
 "category": "__category__",
 "name": "_RFN",
 "displayName": null,
 "type": 20,
 "value": "BAA_RECESSED FIRE EXTINGUISHER CABINET",
 "unit": null,
 "hidden": true
 },
 {
 "category": "__category__",
 "name": "_RC",
 "displayName": null,
 "type": 20,
 "value": "Specialty Equipment",
 "unit": null,
 "hidden": true
 },
 {
 "category": "__child__",
 "name": "child",
 "displayName": null,
 "type": 11,
 "value": 96668,
 "unit": null,
 "hidden": true
 }
 ],
 "parents": [
 96667,
 96665,
 12484,
 1
 ]
 }
 ]
 */
