// Run from the scripts/ folder of Ara 3D Gen after setup-assets. See docs/ASSET_CREDITS.md.
import {writeFileSync} from 'node:fs';
import {buildHuman} from '../src/core/human';
import {triangleCount} from '../src/core/mesh';
import {DEFAULT_PARAMS} from '../src/core/params';
import {runExport,planExport,DEFAULT_EXPORT} from '../src/export';
import {nodeLibrary} from './node-assets';
const lib=await nodeLibrary();
const params={...DEFAULT_PARAMS,name:'Eldoria_Adventurer',gender:1,age:0.52,muscle:0.62,weight:0.47,height:0.52,african:0.65,asian:0.05,caucasian:0.30,hair:'short02',hairColor:'#251a12',outfit:'none',top:'long_tunic',bottom:'trousers',shoes:'combat_boots',accessories:['leather_armor','belt','crossed_straps'],garmentStyles:{long_tunic:{pattern:'solid',color:'#263e58'},trousers:{pattern:'solid',color:'#44392f'}},detail:'low',rig:'game',faceBones:false,faceShapes:false,speechShapes:false,teeth:'none',tongue:false,weapon:'sword'} as any;
const ch=await buildHuman(lib,params);
const settings={...DEFAULT_EXPORT,format:'glb',clips:['idle','walk','run','sword_slash','jump'],weaponFile:'held',stageProps:false,vehicleFile:false} as any;
const plan=planExport(ch,settings);const result=await runExport(lib,ch,plan);writeFileSync('Eldoria_Adventurer_unoptimized.glb',result.data);writeFileSync('Eldoria_Adventurer_params.json',JSON.stringify(params,null,2));
console.log('Triangles',triangleCount(ch.mesh),'materials',ch.mesh.materials.length,'bytes',result.data.length,'height',ch.height,'plan:',plan.summary);console.log(plan.files);
