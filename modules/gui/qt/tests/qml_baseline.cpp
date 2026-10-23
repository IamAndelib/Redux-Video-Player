/*****************************************************************************
 * Copyright (C) 2026 Redux Video Player authors
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
#include "qml_baseline.hpp"

#include <QDir>
#include <QFileInfo>
#include <QImage>
#include <QQuickItem>
#include <QQuickWindow>

namespace {

// A channel may differ this much (anti-aliasing), and this share of the pixels at most.
constexpr int channelTolerance = 8;
constexpr double maxDifferingShare = 0.001;

QImage grab(QQuickItem* item)
{
    const QRectF rect = item->mapRectToScene(QRectF(0, 0, item->width(), item->height()));
    return item->window()->grabWindow().copy(rect.toAlignedRect()).convertToFormat(QImage::Format_ARGB32);
}

bool similar(QRgb a, QRgb b)
{
    return qAbs(qRed(a) - qRed(b)) <= channelTolerance && qAbs(qGreen(a) - qGreen(b)) <= channelTolerance
        && qAbs(qBlue(a) - qBlue(b)) <= channelTolerance && qAbs(qAlpha(a) - qAlpha(b)) <= channelTolerance;
}

} // namespace

QString Baseline::check(QQuickItem* item, const QString& name) const
{
    if (!item || !item->window())
        return QStringLiteral("no item, or it isn't in a window");

    const QImage actual = grab(item);
    const QString baselinePath = QDir(QStringLiteral(REDUX_BASELINE_DIR)).filePath(name + QStringLiteral(".png"));

    if (qEnvironmentVariableIntValue("REDUX_UPDATE_BASELINES"))
    {
        QDir().mkpath(QFileInfo(baselinePath).path());
        return actual.save(baselinePath) ? QString() : QStringLiteral("can't write ") + baselinePath;
    }

    QImage expected(baselinePath);
    if (expected.isNull())
        return QStringLiteral("no baseline %1 (run with REDUX_UPDATE_BASELINES=1)").arg(baselinePath);
    expected = expected.convertToFormat(QImage::Format_ARGB32);

    QString problem;
    QImage diff(actual.size(), QImage::Format_ARGB32);
    diff.fill(Qt::black);
    if (expected.size() != actual.size())
        problem = QStringLiteral("size %1x%2, baseline %3x%4").arg(actual.width()).arg(actual.height())
                      .arg(expected.width()).arg(expected.height());
    else
    {
        qint64 differing = 0;
        for (int y = 0; y < actual.height(); ++y)
            for (int x = 0; x < actual.width(); ++x)
                if (!similar(actual.pixel(x, y), expected.pixel(x, y)))
                {
                    ++differing;
                    diff.setPixel(x, y, qRgb(255, 0, 0));
                }
        if (differing > maxDifferingShare * actual.width() * actual.height())
            problem = QStringLiteral("%1 of %2 pixels differ").arg(differing).arg(actual.width() * actual.height());
    }

    if (!problem.isEmpty())
    {
        const QString out = QDir::current().filePath(QStringLiteral("l4/") + name);
        QDir().mkpath(QFileInfo(out).path());
        actual.save(out + QStringLiteral(".actual.png"));
        diff.save(out + QStringLiteral(".diff.png"));
        problem += QStringLiteral("; see ") + out + QStringLiteral(".actual.png");
    }
    return problem;
}
