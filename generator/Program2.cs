using MdxLib.Animator;
using MdxLib.Model;
using MdxLib.ModelFormats;
using MdxLib.Primitives;
using System.Numerics;

namespace customModelEditor
{
    internal class Program
    {
        static void Main(string[] args)
        {
            string templatePath = "D:\\WC3_Projects\\flappybird\\map.w3x\\sprites\\bird-template3.mdx";
            string outputFolder = "D:\\WC3_Projects\\flappybird\\map.w3x\\sprites\\birdAngles\\";

            CModel baseModel = LoadModel(templatePath);
            baseModel.Sequences[0].IntervalEnd = 119;

            int textureIndex = 0;
            for (int angle = -90; angle <= 40; angle++)
            {
                AddSequence(baseModel);

                if (angle == 40)
                {
                    AddAllTextures(baseModel);
                    AddFlyAnimation(baseModel);
                }
                else
                {
                    AddSingleTexture(baseModel, textureIndex);
                    AddOneFrameAnimation(baseModel);
                    if (angle % 10 == 0) textureIndex = (textureIndex + 1) % 3;
                }

                AddRotation(baseModel, angle);
                string filePath = outputFolder + $"bird{angle}.mdl";
                SaveModel(baseModel, filePath);
                TrimFile(filePath);
            }

            Console.Read();
        }

        static CModel LoadModel(string path)
        {
            CModel model = new();
            using FileStream stream = new(path, FileMode.Open, FileAccess.Read);
            new CMdx().Load(path, stream, model);
            return model;
        }

        static void SaveModel(CModel model, string path)
        {
            using FileStream stream = new(path, FileMode.Create, FileAccess.Write);
            new CMdl().Save(path, stream, model);
            Console.WriteLine(path);
        }

        static void TrimFile(string path) // delete magos' sign
        {
            string content = File.ReadAllText(path);
            int index = content.IndexOf("Version");
            if (index >= 0)
            {
                File.WriteAllText(path, content[index..]);
            }
        }

        static void AddSequence(CModel model)
        {
            CSequence last = model.Sequences[0];
            if (model.Sequences.Count > 1)
            {
                model.Sequences.Remove(model.Sequences[2]);
                model.Sequences.Remove(model.Sequences[1]);
            }

            foreach (string name in new[] { "Morph", "Alternate" })
            {
                CSequence sequence = new(model)
                {
                    Name = name,
                    Extent = last.Extent,
                    NonLooping = false,
                    IntervalStart = last.IntervalEnd + 10,
                    IntervalEnd = last.IntervalEnd + 130
                };
                model.Sequences.Add(sequence);
                last = sequence;
            }
        }

        static void AddAllTextures(CModel model)
        {
            model.Textures.Clear();
            string[][] textureSets =
            {
                new[] { "sprites\\testupscale512.tga", "sprites\\yellowbird-downflap512.tga", "sprites\\yellowbird-upflap512.tga" },
                new[] { "sprites\\redbird-midflap512.tga", "sprites\\redbird-downflap512.tga", "sprites\\redbird-upflap512.tga" },
                new[] { "sprites\\bluebird-midflap512.tga", "sprites\\bluebird-downflap512.tga", "sprites\\bluebird-upflap512.tga" }
            };

            foreach (var set in textureSets)
            {
                foreach (var file in set)
                {
                    model.Textures.Add(new CTexture(model)
                    {
                        WrapWidth = true,
                        WrapHeight = true,
                        FileName = file
                    });
                }
            }
        }

        static void AddSingleTexture(CModel model, int index)
        {
            model.Textures.Clear();
            string[][] textureSets =
            {
                new[] { "sprites\\testupscale512.tga", "sprites\\yellowbird-downflap512.tga", "sprites\\yellowbird-upflap512.tga" },
                new[] { "sprites\\redbird-midflap512.tga", "sprites\\redbird-downflap512.tga", "sprites\\redbird-upflap512.tga" },
                new[] { "sprites\\bluebird-midflap512.tga", "sprites\\bluebird-downflap512.tga", "sprites\\bluebird-upflap512.tga" }
            };

            foreach (var set in textureSets)
            {
                model.Textures.Add(new CTexture(model)
                {
                    WrapWidth = true,
                    WrapHeight = true,
                    FileName = set[index]
                });
            }
        }

        static void AddFlyAnimation(CModel model)
        {
            var animator = model.Materials[0].Layers[0].TextureId;
            animator.Clear();

            int[][] keyframes =
            {
                new[] { 0, 1 }, new[] { 40, 0 }, new[] { 80, 2 },
                new[] { model.Sequences[1].IntervalStart, 4 },
                new[] { model.Sequences[1].IntervalStart + 40, 3 },
                new[] { model.Sequences[1].IntervalStart + 80, 5 },
                new[] { model.Sequences[2].IntervalStart, 7 },
                new[] { model.Sequences[2].IntervalStart + 40, 6 },
                new[] { model.Sequences[2].IntervalStart + 80, 8 }
            };

            foreach (var frame in keyframes)
                animator.Add(new CAnimatorNode<int>(frame[0], frame[1]));

            animator.MakeAnimated();
        }

        static void AddOneFrameAnimation(CModel model)
        {
            var animator = model.Materials[0].Layers[0].TextureId;
            animator.Clear();

            animator.Add(new CAnimatorNode<int>(0, 0));
            animator.Add(new CAnimatorNode<int>(model.Sequences[1].IntervalStart, 1));
            animator.Add(new CAnimatorNode<int>(model.Sequences[2].IntervalStart, 2));

            animator.MakeAnimated();
        }

        static void AddRotation(CModel model, int degrees)
        {
            var rot = model.Bones[0].Rotation;
            rot.Clear();
            rot.MakeAnimated();

            Quaternion q = Quaternion.CreateFromAxisAngle(Vector3.UnitZ, degrees * (float)Math.PI / 180);
            CVector4 rotVec = new(q.X, q.Y, q.Z, q.W);

            foreach (var seq in model.Sequences)
            {
                rot.Add(new CAnimatorNode<CVector4>(seq.IntervalStart == 0 ? 0 : seq.IntervalStart, rotVec));
            }
        }
    }
}
