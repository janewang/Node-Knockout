TheXX.views.Planet = TheXX.View.extend({

  className:  'planet',
  template:   'planet',

  initialize: function() {
    _.bindAll(this, 'generateTexture', 'animatePlanet', 'drawPlanet');
    this.group = new THREE.Object3D();
    this.group.name = this.model.name();
    this.group.position.x = this.model.posX() * 200;
    this.group.position.y = this.model.posY() * 200;
    this.model.on('change', this.change, this);
    this.status = 'noAttack';
    TheXX.on('xx:mousemove', this.mousemove, this)
    this.dimensions = {
      windowWidth: window.innerWidth,
      windowHeight: window.innerHeight
    };
  },

  events: {
    'planetHover':  'hover',
    'mousedown':    'mousedown',
    'mouseup':      'mouseup',
    'mousemove':    'mousemove'
  },
  
  hover: function(arg, hovered) {
    if (this.$('.planetEnv').is(':visible') && hovered == true) return;
    if (!this.$('.planetEnv').is(':visible') && hovered == true) return this.$('.planetEnv').fadeIn();
    this.$('.planetEnv').fadeOut()
  },

  mousedown: function(e) {
    this.stopRotation = true;
    this.group.rotation.x -= 0.005;
  },

  mouseup: function(e) {
    delete this.stopRotation;
  },

  change: function(model) {   
    if (model.name() === this.group.name) {
      this.status = this.model.status();
      this.drawPlanet();
    }
  },

  rendered: function() {
    this.planetType = this.model.type();
    this.drawPlanet();
    this.animatePlanet();
  },

  drawPlanet: function() {
    var material, texture;
    var geometry = new THREE.SphereGeometry(200, 20, 20);
    var textureData = this.generateHeight(1024, 1024);
    
    switch (this.planetType) {
      case 'frigid':
        texture = new THREE.Texture(this.generateTexture(textureData, 1024, 1024, this.planetType));
        break;
      case 'lush':
        texture = new THREE.Texture(this.generateTexture(textureData, 1024, 1000, this.planetType));
        break;
      case 'volcanic':
        texture = new THREE.Texture(this.generateTexture(textureData, 1024, 1024, this.planetType));
        break;
      case 'water':
        texture = new THREE.Texture(this.generateTexture(textureData, 1024, 1024, this.planetType));
        break;
    }
   
    switch (this.status) {
      case 'noAttack':
        material = new THREE.MeshBasicMaterial( { map: texture, overdraw: true } );
        break;
      case 'terraform':
        texture = new THREE.Texture(this.generateTexture(textureData, 1024, 1000, 'lush'));
        material = new THREE.MeshBasicMaterial( { map: texture, overdraw: true } );
        break;
      case 'underAttack':
        texture = new THREE.Texture(this.generateTexture(textureData, 1024, 1000, 'underAttack'));
        material = new THREE.MeshBasicMaterial( { map: texture, overdraw: true } );
        break;
      case 'toAttack':
        texture = new THREE.Texture(this.generateTexture(textureData, 1024, 1000, 'toAttack'));
        material = new THREE.MeshBasicMaterial( { map: texture, overdraw: true } );
        break;
    }
    
    texture.needsUpdate = true;
    material.needsUpdate = true;
    this.mesh = new THREE.Mesh( geometry, material );        
    this.group.add( this.mesh );
    this.group.rotation.y -= 0.005;
  },

  generateHeight: function(width, height) {
   var data = Float32Array ? new Float32Array( width * height ) : [], perlin=new ImprovedNoise(),
   size = width * height, quality = 2, z = Math.random() * 100;
   for (var i = 0; i < size; i++) {
     data[i] = 0;
   }
   for (var j = 0; j<4; j++) {
     quality *= 4;
     for (var i = 0; i<size; i++) {
       var x = i % width, y = ~~ (i / width);
       data[i] += Math.floor( Math.abs(perlin.noise( x / quality, y / quality, z ) * 0.5 ) * quality + 10);
     }
   }
   return data;
  },

  generateTexture: function(data, width, height, planetType) {
   var canvas, context, image, imageData, level, diff, vector3, planet, shade, surface;

   surface = planetType;
   vector3 = new THREE.Vector3(0, 0, 0);
   planet = new THREE.Vector3(1, 1, 1);
   planet.normalize();

   canvas = $('<canvas />', {width: width, height: height})[0];

   context = canvas.getContext('2d');
   context.fillStyle = '#000';
   context.fillRect(0, 0, width, height);

   image = context.getImageData(0, 0, width, height);
   imageData = image.data;

   switch (surface) {
      case 'frigid':
        for (var i = 0, j = 0, l = imageData.length; i < l; i += 4, j++) {
         vector3.x = data[j - 1] - data[j + 1];
         vector3.y = 2;
         vector3.z = data[j - width] - data[j + width];
         vector3.normalize();
         shade = vector3.dot(planet);
         imageData[i] = (230 + shade * 128) * (data[j] * 0.007);
         imageData[i + 1] = (220 + shade * 96 ) * (data[j] * 0.007);
         imageData[i + 2] = ( 220 ) * (data[j] * 0.007);
        }
        break;
      case 'lush':
        for (var i = 0, j = 0, l = imageData.length; i < l; i += 4, j++) {
         vector3.x = data[j - 1] - data[j + 1];
         vector3.y = 2;
         vector3.z = data[j - width] - data[j + width];
         vector3.normalize();
         shade = vector3.dot(planet);
         imageData[i] = ( 0 ) * (data[j] * 0.007);
         imageData[i + 1] = (110) * (data[j] * 0.007);
         imageData[i + 2] = (shade * 96) * (data[j] * 0.007);
       }
        break;
      case 'volcanic':
        for (var i = 0, j = 0, l = imageData.length; i < l; i += 4, j++) {
          vector3.x = data[j - 1] - data[j + 1];
          vector3.y = 2;
          vector3.z = data[j - width] - data[j + width];
          vector3.normalize();
          shade = vector3.dot(planet);
          imageData[i] = ( 96 + shade * 128) * (data[j] * 0.007);
          imageData[i + 1] = ( 0 + shade * 96) * (data[j] * 0.007);
          imageData[i + 2] = (shade * 96) * (data[j] * 0.007);
        }
        break;
      case 'water':
        for (var i = 0, j = 0, l = imageData.length; i < l; i += 4, j++) {
          vector3.x = data[j - 1] - data[j + 1];
          vector3.y = 2;
          vector3.z = data[j - width] - data[j + width];
          vector3.normalize();
          shade = vector3.dot(planet);
          imageData[i] = ( 108 ) * (data[j] * 0.007);
          imageData[i + 1] = ( 140 ) * (data[j] * 0.007);
          imageData[i + 2] = ( 213 ) * (data[j] * 0.007);
        }
        break;
      case 'toAttack':
        for (var i = 0, j = 0, l = imageData.length; i < l; i += 4, j++) {
          vector3.x = data[j - 1] - data[j + 1];
          vector3.y = 2;
          vector3.z = data[j - width] - data[j + width];
          vector3.normalize();
          shade = vector3.dot(planet);
          imageData[i] = ( 49 ) * (data[j] * 0.007);
          imageData[i + 1] = ( 79 + shade * 96) * (data[j] * 0.007);
          imageData[i + 2] = (79) * (data[j] * 0.007);
        }
        break;
      case 'underAttack':
        for (var i = 0, j = 0, l = imageData.length; i < l; i += 4, j++) {
          vector3.x = data[j - 1] - data[j + 1];
          vector3.y = 2;
          vector3.z = data[j - width] - data[j + width];
          vector3.normalize();
          shade = vector3.dot(planet);
          imageData[i] = ( 255 ) * (data[j] * 0.007);
          imageData[i + 1] = ( 0 + shade * 96) * (data[j] * 0.007);
          imageData[i + 2] = (0) * (data[j] * 0.007);
        }
        break;
    }
   context.putImageData(image, 0, 0);
   return canvas;
  },

  animatePlanet: function() {
    requestAnimationFrame(this.animatePlanet);
    this.group.rotation.y -= 0.005;
  },
  
  mousemove: function(e) {
    e.preventDefault();
    this.group.rotation.y = (e.offsetX * 0.002);
    this.group.rotation.x = (e.offsetY * 0.002);
  }
  
});
