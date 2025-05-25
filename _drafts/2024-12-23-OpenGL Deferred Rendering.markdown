---
layout: post
title: "OpenGL Deferred Rendering"
date: 2024-12-22 15:13:15 -0700
image: /assets/images/OpenGLParallaxMapping/cropped-OpenGL_Parallax_12.png
categories: jekyll update main
permalink:  
tags: OpenGL GLSL
---

<div class="reusable-divider">
    <span class="small-header-text">PROJECT DESCRIPTION</span>
    <hr>
</div>

For this project I decided to try and expand upon my deferred rendering pipeline to incorporate parallax mapping. I had significant difficulty with correctly calculating the tangent and bitangent vectors, but I believe that the issue is with how the UVs are unwrapped in Blender rather than an issue with my calculations. 

<div class="reusable-divider">
    <span class="small-header-text">THEORETICAL BACKGROUND</span>
    <hr>
</div>

Parallax mapping is a technique for significantly increasing the detail of a surface without adding extra geometry. It is similar to displacement mapping, but instead of requiring extra geometry to create realistic depth, it offsets the surface texture coordinates based on view direction and a height map. 

![Image1](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_11.png){: .center }


<div class="reusable-divider">
    <span class="small-header-text">MATHEMATICAL CONCEPTS</span>
    <hr>
</div>

* **TBN Matrix:** The texture coordinates for parallax mapping are in tangent space. Tangent space is the space that is local to the surface of a triangle, where the normal, tangent, and bitangent vectors point in the positive up, right, and forward direction respectively. To correctly calculate the parallax offset, the view direction vector  needs to be in the same space as the texture coordinates. Thus, a change of basis matrix is needed to transform the view direction vector from world space to tangent space.


* **Basis:**  is a set of vectors such that the set is linearly independent and they span a subspace of H.

* **Change of Basis Matrix:** a matrix that is used to convert a vector from its representation in one basis to its representation in another basis. 

To calculate the change of basis matrix, a tangent, bitagent, and normal vector are needed for each vertex. While 3d modeling software like blender typically export objects with normal data, they do not contain per vertex tangent and bitangent data by default. Thus, these vectors usually have to be computed either at runtime or when imported.   

The tangent and bitangent vectors can be derived from the texture coordinate and position data of vertices. Edges formed from the texture coordinates of each triangle can be described as a linear combination of the tangent and bitangent vector. Thus, this problem can be written as a system of linear equations, which can be solved by using the inverse of the texcoord differences. Note that it can be difficult to get parallax mapping to work correctly for all faces of a mesh because of the orientation of the texture coordinates. The direction of the tangent and bitangent vector can vary depending on the orientation of the texture coordinates on the mesh, which can result in artifacts. 

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_1.png){: .center }

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_2.png){: .center }

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_3.png){: .center }


For a right-handed coordinate system, the bitangent vector can also be calculated using the cross product of the tangent and normal vector. Using the cross product method is generally more reliable because it is not dependent on the texcoords alignment with the surface geometry, which can sometimes be incorrect. 


The resulting tangent and bitangent vectors are transformed to world space, normalized to ensure an orthonormal basis, and stored in separate textures. Then in the parallax fragment shader, the TBN matrix is defined as the transpose of a matrix with column vectors tangent, bitangent, and normal.

The way in which tangent and bitangent vectors are computed results in parallax mapping being heavily dependent on the orientation of the mesh's texture coordinates. Thus, it can be difficult to get the parallax effect to work as expected, especially for more complicated meshes.Blender allows you to include tangent and bitangent data when exporting an object as an .fbx. Therefore, to avoid having to compute the tangent and bitangent vectors, I have removed the vertices array that holds the vertex data for a cube and instead import the cube using assimp. Unfortunately, this method also had the same issue despite unwrapping the mesh using cube projection, which should produce the correct tangent and bitangent vectors. However, I was able to improve the effect by flipping the bitangent vector when creating the TBN matrix.

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_12.png){: .center }

**View Direction Vector:**


The view direction vector is a vector that points from the current fragment position in the scene towards the camera position. It can be calculated by subtracting the fragment’s position in world space from the camera position. As mentioned previously, the TBN matrix is used to transform the view direction vector from world space to tangent space. The image below is taken from a Unity universal render pipeline (URP) shader graph, and gives a visual representation of that calculation. In this case, the transform node represents the view direction - TBN matrix multiplication. 

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_4.png){: .center }


**Parallax Mapping:**


Parallax mapping can be implemented in several ways. The least computationally expensive method is to sample the displacement map at the point where the view direction vector intersects with the object. Using the displacement amount at the intersection point, extend out from the view direction vector the same amount and sample the displacement amount at that point. This approximates the displacement amount and produces a convincing result if the view angle is not steep, but breaks down as the view angle increases as the approximate value deviates significantly from the real value. 

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_5.png){: .center }



An alternative method that offers more accurate results is steep parallax mapping. This method involves sampling the displacement map at multiple layers in the direction of the view vector until the layer's depth is greater than the value in the displacement map. To enhance the approximation, linear interpolation between the layer before and after the collision can be used. This approach is known as parallax occlusion mapping. In this project, I use steep parallax mapping. 


![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_6.png){: .center }


<div class="reusable-divider">
    <span class="small-header-text">FLOWCHART</span>
    <hr>
</div>


The following flowchart outlines the process used to compute the TBN matrix using a geometry pass in the gbuffer shader and how that is used to calculate the parallax mapping. 

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_7.png){: .center }




<div class="reusable-divider">
    <span class="small-header-text">SCREENSHOTS</span>
    <hr>
</div>


![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_8.png){: .center }

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_9.png){: .center }

When two parallax-mapped objects intersect, the algorithm used to calculate the parallax mapping effect may result in stretching artifacts. The algorithm is based on the assumption that the surface of the object is continuous and not intersecting with other surfaces, which can be resolved using a more complex algorithm. 

![Image8](/assets/images/OpenGLParallaxMapping/OpenGL_Parallax_10.png){: .center }

As mentioned previously, when the texture coordinates are not properly aligned, the tangent and bitangent vectors may face the wrong direction. This results in the parallax effect not moving in the correct direction with respect to the view direction vector. 


<div class="reusable-divider">
    <span class="small-header-text">LINKS</span>
    <hr>
</div>

1. [Learn OpenGL Parallax Mapping](https://learnopengl.com/Advanced-Lighting/Parallax-Mapping)
2. [Learn OpenGL Parallax Mapping Code](https://learnopengl.com/code_viewer_gh.php?code=src/5.advanced_lighting/5.2.steep_parallax_mapping/steep_parallax_mapping.cpp)
3. [Learn OpenGL Normal Mapping](https://learnopengl.com/Advanced-Lighting/Normal-Mapping#:~:text=The%20great%20thing%20about%20tangent,Tangent%20%2C%20Bitangent%20and%20Normal%20vector.)
4. [Cem Yuksel Parallax Mapping](https://www.youtube.com/watch?v=cM7RjEtZGHw&ab_channel=CemYuksel)
5. [gamedev.net Parallax Occlusion Mapping](https://www.gamedev.net/tutorials/programming/graphics/a-closer-look-at-parallax-occlusion-mapping-r3262/)


[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
