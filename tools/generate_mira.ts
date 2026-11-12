// Run from the scripts/ folder of Ara 3D Gen after setup-assets. See docs/ASSET_CREDITS.md.
import {writeFileSync} from 'node:fs';
import {buildHuman} from '../src/core/human';
import {triangleCount} from '../src/core/mesh';
import {DEFAULT_PARAMS} from '../src/core/params';
import {runExport,planExport,DEFAULT_EXPORT} from '../src/export';
import {nodeLibrary} from './node-assets';
const lib=await nodeLibrary();
const params={...DEFAULT_PARAMS,name:'Eldoria_Mira',gender:0,age:0.55,muscle:0.4,weight:0.44,height:0.46,african:0.72,asian:0.08,caucasian:0.20,hair:'braid01',hairColor:'#271a14',outfit:'none',top:'long_tunic',bottom:'trousers',shoes:'combat_boots',accessories:['belt'],garmentStyles:{long_tunic:{pattern:'solid',color:'#967754'},trousers:{pattern:'solid',color:'#504237'}},detail:'low',rig:'game',faceBones:false,faceShapes:false,speechShapes:false,teeth:'none',tongue:false,weapon:'none'} as any;
const ch=await buildHuman(lib,params);
const settings={...DEFAULT_EXPORT,format:'glb',clips:['idle','walk'],weaponFile:'held',stageProps:false,vehicleFile:false} as any;
const plan=planExport(ch,settings);const result=await runExport(lib,ch,plan);writeFileSync('Eldoria_Mira_unoptimized.glb',result.data);writeFileSync('Eldoria_Mira_params.json',JSON.stringify(params,null,2));
console.log('Triangles',triangleCount(ch.mesh),'materials',ch.mesh.materials.length,'bytes',result.data.length,'height',ch.height,'plan:',plan.summary);
