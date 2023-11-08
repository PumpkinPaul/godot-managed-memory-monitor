using Godot;
using System;

namespace SpleenWeevil.DebugTools;

public partial class MemoryMonitor : Node
{
    private const int MAX_GRAPH_FRAMES = 180;

    readonly float[] _tickBytes = new float[MAX_GRAPH_FRAMES];
    readonly float[] _totalMegabytes = new float[MAX_GRAPH_FRAMES];

    float[][] _collections;

    int[] _maxCollections;
    string[] _genNames;
    int _frameId = -1;

    long _totalMemory;
    long _previousMemory;
    long _tickMemory;

    public int GetCollectionCount(int generation) => _maxCollections[generation];
    public int GetTickMemoryMB() => (int)_tickBytes[_frameId];
    public float GetTotalMemoryMB() => _totalMegabytes[_frameId];

    public override void _Ready()
    {
        _totalMemory = GC.GetTotalMemory(false);
        _previousMemory = _tickMemory;

        var maxGenerations = GC.MaxGeneration + 1;
        _maxCollections = new int[maxGenerations];
        _genNames = new string[maxGenerations];
        _collections = new float[maxGenerations][];
        for (var i = 0; i < maxGenerations; i++)
        {
            _genNames[i] = $"Gen {i}";
            _collections[i] = new float[MAX_GRAPH_FRAMES];
        }
    }

    public override void _Process(double delta)
    {
        _totalMemory = GC.GetTotalMemory(false);
        _tickMemory = Math.Max(0, _totalMemory - _previousMemory);
        _previousMemory = _totalMemory;

        _frameId = (_frameId + 1) % MAX_GRAPH_FRAMES;

        _tickBytes[_frameId] = _tickMemory;
        _totalMegabytes[_frameId] = _totalMemory / 1024.0f / 1024.0f;

        for (var i = 0; i < _collections.Length; i++)
        {
            var count = GC.CollectionCount(i);
            if (count > _maxCollections[i])
                _maxCollections[i] = count;

            _collections[i][_frameId] = _maxCollections[i];
        }
    }
}