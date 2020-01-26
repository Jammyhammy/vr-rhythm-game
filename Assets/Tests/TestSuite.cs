using System.Collections;
using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;

namespace Tests
{
    public class TestSuite
    {
        private SaberGame game;
        // A Test behaves as an ordinary method
        [Test]
        public void TestSuiteSimplePasses()
        {
            // Use the Assert class to test conditions
            // Check if our game manager has been instantiated.
            Assert.IsNotNull(game);
        }

        // A UnityTest behaves like a coroutine in Play Mode. In Edit Mode you can use
        // `yield return null;` to skip a frame.

        [UnityTest]
        public IEnumerator TestSuiteWithEnumeratorPasses()
        {
            // Use the Assert class to test conditions.
            // Use yield to skip a frame.
            yield return null;
        }

        [UnityTest]
        public IEnumerator TestBlockGame() {
            //The block should traverse along a rhythm path.
            GameObject go = MonoBehaviour.Instantiate(Resources.Load<GameObject>("Prefabs/RedBlockSlicable"));
            float initialYPos = go.transform.position.y;
            yield return new WaitForSeconds(1.0f);
            Assert.AreNotEqual(initialYPos, go.transform.position.y);
        }

        [UnityTest]
        public IEnumerator TestIfBlockHasBeenCreated() {
            GameObject go = MonoBehaviour.Instantiate(Resources.Load<GameObject>("Prefabs/RedBlockSlicable"));
            yield return new WaitForSeconds(0.1f);
            Assert.IsNotNull(go);
        }

        [UnityTest]
        public IEnumerator TestIfBlockIsSliced() {
            GameObject go = MonoBehaviour.Instantiate(Resources.Load<GameObject>("Prefabs/RedBlockSlicable"));
            yield return new WaitForSeconds(2.0f); // Let it traverse to player.
            // Then register initial slice hit.
            var blockHitReporter = go.GetComponent<BlockHitReporter>();
            blockHitReporter.blockSliceDetector.testSlice = true;
            blockHitReporter.blockSliceDetector.RegisterCollision1();
            yield return new WaitForSeconds(0.15f); // Amount of time before block is sliced
            // Register slice through block.
            blockHitReporter.blockSliceDetector.RegisterCollision2();
            // Check if block was sliced.
            Assert.IsTrue(blockHitReporter.isFinalCollision);
        }        
        
        //The SetUp attribute specifies that this method is called before each test is run.
        [SetUp]
        public void ResetScene()
        {
            //Set up an empty game scene as our testing environment.
            EditorSceneManager.NewScene(NewSceneSetup.EmptyScene); 
            //Instantiate the game manager.
            game = MonoBehaviour.Instantiate(Resources.Load<GameObject>("Prefabs/SaberGame")).GetComponent<SaberGame>();
        }

        //The TearDown attribute specifies that this method is called after each test is run.
        [TearDown]
        public void Teardown()
        {
            //Reset the game manager.
            Object.Destroy(game.gameObject);
        }

    }
}
